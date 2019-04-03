class WebserviceClient
  include HTTParty

  base_uri  Setting.plugin_sso_portal_integration[:url_validate_sso]
  format :json

  def validate(token,app_id)
    uri = self.class.base_uri
    resource = "/" if uri[uri.size-1] != "/"
    resource ||= ""
    resource += app_id + '/' + token
    hash = self.class.get(resource, headers: {'Content-Type' => 'application/json'})
    hash
  end

end
