class CertifiedSupplierResource
  include HTTParty

  base_uri Setting.plugin_nf_xml_to_form['base_url']

  def self.certified_supplier(issue)
    JSON.parse(get("/certified_supplier", { query: build_query(issue) }).body).first
  end

  def self.build_query(issue)
    cnpj = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["cnpj_contrato"])
    cnpj = cnpj.gsub(".","").gsub("/","").gsub("-","")
    {
      cnpj: cnpj
    }
  end
end
