Redmine::Plugin.register :pac_consultoria_geral do
  name 'Pac Consultoria Geral plugin'
  author 'Visagio'
  description 'Plugin para customização e validação dos PACs eletrônicos'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  # require_dependency 'action_view'
  require 'pac_pdf_helper'
  require 'pac_consultoria_geral/hooks/issue_hook'

  settings default: {}, :partial => 'settings/pac_consultoria_geral'

end

Rails.configuration.after_initialize do
  AssignToGestorContratoJob.register
  AssignToConsultorGeralJob.register
  AssignToGerenteJob.register
  CertifiedSupplierJob.register
  SetConsultorGeralJob.register
  SetPacSubjectJob.register
  ValidateCompanyDistributionSumJob.register
  ValidateVigenciaJob.register
  ValidateTipoPacJob.register
  ValidateMetodoContratacaoJob.register
end
