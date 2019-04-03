module API
  module V1
    class Permissions < Grape::API
      #URL {root-url}/api/:resource
      #HEADER: Accept: application/vnd.api-{:version}+json, Content-Type: application/vnd.api+json
      version 'v1', using: :header, vendor: :api
      format :json

      helpers do
        def permissions_list
          hash_permissions = []
          hash_permissions << group_list(Group.where("type <> 'GroupNonMember'").where("type <> 'GroupAnonymous'"))
          hash_permissions
        end

        def group_list(groups)
          return nil if groups.blank?

          hash = {key: 'groups', displayValue: I18n.t('label_group_plural'), availableValues:[]}

          groups.each do |group|
            hash[:availableValues] << [group.id.to_s, group.name]
          end

          return hash
        end
      end

      resource :permissions do
        desc "Return list of Groups"
        get do
          hash = {}
          hash["permissions"] = permissions_list
          hash
        end
      end
    end
  end
end
