class CertifiedSupplierJob < ExecJob
  unloadable

  def perform(issue, retry_num=0)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue)

    certified_supplier = CertifiedSupplierResource.certified_supplier(issue)
    issue.custom_field_values = {
      Setting.plugin_pac_consultoria_geral["fornecedor_certificado"].to_i =>certified_supplier["certified_supplier"]
    }
  end
end
