module API
  module V1
    class SyncUser < Grape::API
      #URL {root-url}/api/:resource
      #HEADER: Accept: application/vnd.api-{:version}+json, Content-Type: application/vnd.api+json
      version 'v1', using: :header, vendor: :api
      format :json

      helpers do
        def validate_response(response)
          if response.blank? || response["status"] != "OK"
            if response.response.blank?
              raise Exception.new('Token validation response error.')
            else
              raise Exception.new("Token validation response: " + response.response.code + " - " + response.response.msg.to_s + " Requested URL: " + response.request.last_uri.to_s)
            end
            if response["status"] == "INVALID_TOKEN"
              raise Exception.new("Token authentication falied: " + response["status"])
            end
            return false
          else
            return true
          end
        end

        def update_create_user (user, user_json, permissions_json)
          if user.nil?
            User.create_user_json(user_json, permissions_json)
          else
            User.update_user_json(user, user_json, permissions_json)
          end
        end

        def remove_user (user)
          if user.nil?
            raise Exception.new('User not found: ' + response["user"]["email"])
          end
          User.remove_user(user)
        end
      end

      resource :syncUser do
        desc "Return list of Groups"
        get do

          hash = {}
          token = params[:token]
          app_id = Setting.plugin_sso_portal_integration[:config_id_sso]

          begin
            response = WebserviceClient.new.validate(token,app_id)

            if validate_response(response)
              tokenType = response["tokenType"]
              user =  User.find_by_mail(response["user"]["email"])

              if tokenType == 'UPDATE'
                update_create_user(user,response["user"], response["permissions"])
                hash["status"] = "OK"
              elsif (tokenType == 'DELETE')
                remove_user(user)
                hash["status"] = "OK"
              else
                raise Exception.new('Invalid token type: ' + tokenType)
              end
            end
          rescue Exception => e
            Rails.logger.error ("An error occured in user synchronization: #{e.message}")
            hash["status"] = "FALIED"
          end
          hash
        end
      end

    end
  end
end
