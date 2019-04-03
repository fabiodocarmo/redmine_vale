Redmine::Plugin.register :nf_xml_to_form do
  name 'Nf Xml To Form plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require 'xml_converter'
  require 'transport_xml_converter'
  require 'material_xml_converter'
  require 'nf_xml_to_form/hooks/issue_hook'


  settings default: {}, :partial => 'settings/nf_xml_to_form'

  project_module :csv_converter do
    permission :csv_converter,
               { :csv_converter => [:index, :convert] }
  end

  menu :project_menu, :csv_converter,
       {controller: :csv_converter, action: :index },
       caption: :csv_converter, param: :project_id

end

Rails.configuration.after_initialize do
  DueDateJob.register
  ValidateEmissionDateGreaterThanCreatedOnJob.register
  ValidateTaxRateAndValueJob.register
  CalculateTaxesBaseValueJob.register
  FormatPostingDateJob.register
  AutoForwardIssueToGrcJob.register
  AutoForwardIssueToRobotJob.register
  ValidateInitialDateGreaterThanEndDateJob.register
  ValidateAuthorshipIndicativeJob.register
  ValidateWithheldTaxJob.register
  EmailToNfJob.register
end
