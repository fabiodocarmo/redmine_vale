module Patches
  module SsoApplicationControllerPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        alias_method_chain :session_expiration, :sso
      end
    end

    def session_expiration_with_sso
      if session[:user_id]
        if session_expired? && !try_to_autologin
          set_localization(User.active.find_by_id(session[:user_id]))
          self.logged_user = nil
          if !(params[:controller] == 'account' && params[:action]=='sso_login' && params[:token]!=nil)
            flash[:error] = l(:error_session_expired)
            require_login
          end
        else
          session[:atime] = Time.now.utc.to_i
        end
      end
    end

  end
end
