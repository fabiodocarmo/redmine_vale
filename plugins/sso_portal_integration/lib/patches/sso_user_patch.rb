
module Patches
  module SsoUserPatch
    def self.included(base) # :nodoc:

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :change_password_allowed?, :sso

        def self.update_user_json(user, user_json, permissions_json)
          user.mail = user_json["email"]
          user.firstname = user_json["firstName"]
          user.lastname = user_json["lastName"]

          if (!user.lastname || user.lastname == "" || user.lastname == " ")
            user.lastname="_"
          end

          set_language(user, user_json["language"] )
          user.activate
          groups = []

          if !permissions_json.blank? && !permissions_json["groups"].blank? && !permissions_json["groups"]["values"].blank?
            group_ids = permissions_json["groups"]["values"]
            groups = Group.where(id: group_ids) unless group_ids.blank?
          end

          user.groups = groups
          user.save!
          user.reload
          logger.info("User '#{user.login}' synchronized with SSO Portal")
          logger.info("Permissions: " + group_ids.to_s)
          user.update_column(:last_login_on, Time.now) if user && !user.new_record?
        end

        def self.remove_user(user)
          groups = []
          members = []
          if (user)
           user.groups = groups
           user.members = members
           user.status = 3 #status 3 = blocked
           user.save
          end
        end

        def self.create_user_json(user_json, permissions_json)
          user = User.new({ "mail" => user_json["email"],
                            "firstname" => user_json["firstName"],
                            "lastname" => user_json["lastName"]})

          if (!user.lastname || user.lastname == "" || user.lastname == " ")
            user.lastname="_"
          end
          
          user.login = user_json["login"]
          set_language(user, user_json["language"] )

          groups = []
          if !permissions_json.blank? && !permissions_json["groups"].blank? && !permissions_json["groups"]["values"].blank?
            group_ids = permissions_json["groups"]["values"]
            if !group_ids.blank?
              group_ids.each do |g|
                groups << Group.find(g.to_i)
              end
            end
          end
          user.save! # :validate => false

          user.reload
          user.groups = groups
          user.save!
          logger.info("User '#{user.login}' created from SSO Portal")
          logger.info("Permissions: " + group_ids.to_s)
          user.update_column(:last_login_on, Time.now) if user && !user.new_record? && user.active?
          user
        end

        def self.set_language(user, language)
          if (language.nil?)
            user.language = Setting.default_language
            return
          end
          language = language.gsub '_', '-'

          if language.eql?("en-US")
            language="en"
          end

          if !valid_languages.include?(language.to_sym)
            user.language = Setting.default_language
          else
            user.language = language
          end
        end
      end
    end

    def change_password_allowed_with_sso?
      return false if Setting.plugin_sso_portal_integration[:disable_regular_login] == "true"
      change_password_allowed_without_sso?
    end
  end
end
