class ExternalValidationResource
  include HTTParty

  base_uri Setting.plugin_redmine_external_validation['base_url']

  def self.validations(external_validation, issue)
    external_validation.queries(issue).each_with_index.map do |query, i|
      { build_key(external_validation, issue, i) => JSON.parse(get('/validations', { query: query }).body).first }
    end
  end

  def self.build_key(external_validation, issue, i)
    external_validation.queries_with_column_grid_id(issue)[i]
  end
end
