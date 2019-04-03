Redmine::Plugin.register :grid_custom_field do
  name 'Grid Custom Field plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '1.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require 'hooks/issues_grid_hook_listener'
  settings default: {}, partial: 'settings/grid_settings'

  Redmine::FieldFormat.send(:include, Patches::FieldFormatPatch) unless Redmine::FieldFormat.included_modules.include?(Patches::FieldFormatPatch)
  Redmine::FieldFormat::Base.send(:include, Patches::FieldFormatBasePatch) unless Redmine::FieldFormat::Base.included_modules.include?(Patches::FieldFormatBasePatch)

  CustomValue.send(:include, Patches::CustomValuePatch) unless CustomValue.included_modules.include?(Patches::CustomValuePatch)
  CustomFieldValue.send(:include, Patches::CustomFieldValuePatch) unless CustomFieldValue.included_modules.include?(Patches::CustomFieldValuePatch)
  CustomField.send(:include, Patches::CustomFieldPatch) unless CustomField.included_modules.include?(Patches::CustomFieldPatch)
  CustomFieldsHelper.send(:include, Patches::CustomFieldsHelperPatch) unless CustomFieldsHelper.included_modules.include?(Patches::CustomFieldsHelperPatch)
  CustomFieldsController.send(:include, Patches::CustomFieldsControllerPatch) unless CustomFieldsController.included_modules.include?(Patches::CustomFieldsControllerPatch)
  Issue.send(:include, Patches::GridIssuePatch) unless Issue.included_modules.include?(Patches::GridIssuePatch)
  IssuesHelper.send(:include, Patches::IssuesHelperPatch) unless IssuesHelper.included_modules.include?(Patches::IssuesHelperPatch)
  QueriesHelper.send(:include, Patches::QueriesHelperPatch) unless QueriesHelper.included_modules.include?(Patches::QueriesHelperPatch)
end
