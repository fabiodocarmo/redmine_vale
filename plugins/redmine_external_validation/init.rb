Redmine::Plugin.register :redmine_external_validation do
  name 'Redmine External Validation plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :external_validations, { controller: 'external_validations', action: 'index' }

  Issue.send(:include, RedmineExternalValidation::Patches::IssuePatch) unless Issue.included_modules.include? RedmineExternalValidation::Patches::IssuePatch
  settings default: {}, partial: 'settings/redmine_external_validation'
end

Rails.configuration.after_initialize do
  CalculateValueBaseWithIvaJob.register
  Cepom::CepomRjJob.register
  AddRemoveDeviationJob.register
end