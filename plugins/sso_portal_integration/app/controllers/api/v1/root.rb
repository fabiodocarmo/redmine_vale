module API
  module V1
    class Root < Grape::API
      mount API::V1::Permissions
      mount API::V1::SyncUser
    end
  end
end
