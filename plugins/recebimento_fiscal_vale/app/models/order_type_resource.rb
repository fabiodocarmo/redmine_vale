class OrderTypeResource
  include HTTParty

  base_uri Setting.plugin_nf_xml_to_form['base_url']

  def self.order_type(issue)
    JSON.parse(get("/validations", { query: build_query(issue) }).body)
      .first.try('[]', 'tipo_pedido') ||
        Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'default')
  end

  def self.build_query(issue)
    {
      pedido: issue.custom_field_value(Setting.plugin_nf_xml_to_form['pedido'])
    }
  end
end