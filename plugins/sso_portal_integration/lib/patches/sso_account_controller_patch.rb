module Patches
  module SsoAccountControllerPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :login, :sso
	      alias_method_chain :successful_authentication, :sso
      end
    end

    def login_with_sso
      if Setting.plugin_sso_portal_integration[:disable_regular_login] == "true"
        backurl = params[:back_url]
        if (backurl && backurl != Setting.protocol+'://'+Setting.host_name+'/' &&
        Setting.plugin_sso_portal_integration[:url_login_sso] &&
        Setting.plugin_sso_portal_integration[:app_id_fieldname_sso] &&
        Setting.plugin_sso_portal_integration[:config_id_sso] &&
        Setting.plugin_sso_portal_integration[:backurl_fieldname_sso])
          redirect_to Setting.plugin_sso_portal_integration[:url_login_sso] + '?'+
          Setting.plugin_sso_portal_integration[:app_id_fieldname_sso] + '=' +
          Setting.plugin_sso_portal_integration[:config_id_sso] +  '&' +
          Setting.plugin_sso_portal_integration[:backurl_fieldname_sso] + '='+
          backurl
        else
          redirect_to Setting.plugin_sso_portal_integration[:url_login_sso]
        end
      else
        login_without_sso
      end
    end

 def successful_authentication_with_sso(user)
      logger.info "Successful authentication for '#{user.login}' from #{request.remote_ip} at #{Time.now.utc}"
      # Valid user
      self.logged_user = user
      # generate a key and set cookie if autologin
      if params[:autologin] && Setting.autologin?
        set_autologin_cookie(user)
      end
      call_hook(:controller_account_success_authentication_after, {:user => user })
      backurl = params[:backurl]
      if (backurl)
        redirect_back_or_default backurl
      else
        redirect_back_or_default home_url
      end
    end

    def sso_authenticate_user(token, backurl)
      app_id = Setting.plugin_sso_portal_integration[:config_id_sso]
      raise "The configuration of ID of the SSO Portal is missing" if app_id.blank?

      response = validate(token,app_id)
      return nil if response.blank?

      groups = response['permissions']['groups']['values'] rescue []
      if (groups & ['12281', '12359', '12370']).any?
        response["user"]["language"] = 'pt-BR'
      end

      if User.current.logged? && User.current.mail == response["user"]["email"]
        User.update_user_json(User.current,response["user"], response['permissions'])
        if (backurl)
          redirect_back_or_default backurl
        else
          redirect_back_or_default home_url
        end
      else
        user = sso_find_user(response["user"]["email"])
        if user.nil?
          user = User.create_user_json(response["user"], response["permissions"])
          successful_authentication(user)
        else
          User.update_user_json(user,response["user"], response['permissions'])

          successful_authentication(user)

        end
      end
    end

    # Login request and validation
    def sso_login
      token = params[:token]
	backurl = params[:backurl]
      if request.get?
        sso_authenticate_user(token, backurl)
      end
    rescue => e
      if e && e.message
        logger.error e.message
        logger.error e.backtrace.join("\n")
        render_error :message => l('error_authentication')
      else
        logger.error l('error_authentication')
        render_error :message => l('error_authentication')
      end
    end

    def sso_find_user(email)
      User.find_by_mail(email)
    end

    def validate(token,app_id)
      response = WebserviceClient.new.validate(token,app_id)
      if response.blank? || response["status"] != "OK"
        if response.response.blank?
          puts "Erro na resposta do validate"
        else
          puts "Resposta do validate: " + response.response.code + " - " + response.response.msg.to_s
          puts "Requested URL: " + response.request.last_uri.to_s
        end
        if response["status"] == "INVALID_TOKEN"
          puts "Falha na autenticação: " + response["status"]
          invalid_credentials
        end
        return nil
      end
      response
    end
  end
end
