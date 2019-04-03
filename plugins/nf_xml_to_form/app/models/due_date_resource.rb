class DueDateResource
  include HTTParty

  base_uri Setting.plugin_nf_xml_to_form['base_url']

  def self.due_date(issue)
    JSON.parse(get("/due_dates", { query: build_query(issue) }).body).first
  end

  def self.build_query(issue)
    {
      pedido: issue.custom_field_value(Setting.plugin_nf_xml_to_form['pedido'])
    }
  end
end
