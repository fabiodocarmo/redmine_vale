require 'redmine'
require 'dependent_fields_management/issue_patch'
require 'dependent_fields_management/hooks/issue_hook'
require 'dependent_fields_management/services/import_rules'

Redmine::Plugin.register :redmine_dependent_fields_management do
  name 'Dependent Custom Fields Management Plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine to set a dependency between two custom fields.'
  version '1.2.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  Rails.configuration.to_prepare do
    Issue.send(:include, DependentFieldsManagement::IssuePatch)
    Redmine::FieldFormat::ListFormat.send(:include, DependentFieldsManagement::ListFormatPatch)
  end

  menu :admin_menu, :dependent_fields, { controller: 'dependent_fields', action: 'index' }

end
