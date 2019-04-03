Redmine::Plugin.register :bm_xls_to_form do
  name 'Célula de Contratos'
  author 'Visagio'
  description 'Plugin para o formulário de Envio de Medição de Serviço'
  version '1.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require 'bm_xls_parser'
  require 'bm_status_helper'
  require 'bm_xls_to_form/hooks/issue_hook'


  settings default: {}, :partial => 'settings/bm_xls_to_form'

  project_module :req_to_pay_upload do
    permission :req_to_pay_upload,
               { :req_to_pay_upload => [:index, :upload] }
  end

  menu :project_menu, :req_to_pay_upload,
       {controller: :req_to_pay_upload, action: :index },
       caption: :req_to_pay_upload, param: :project_id

end

Rails.configuration.after_initialize do
  BMStatusChangeJob.register
end