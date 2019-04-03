class ExternalErpDataResource
  include HTTParty

  base_uri Setting.plugin_redmine_external_validation['base_url']

  def self.erp_data(query)
    JSON.parse(get('/erp_datas', { query: query }).body).first
  end
end