Redmine::Plugin.register :redmine_improve_custom_fields do
  name 'Redmine Improve Fields plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine'
  version '1.11'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require_dependency 'redmine_improve_custom_fields/hooks/custom_field_hook'
  require_dependency 'redmine_improve_custom_fields/hooks/issue_form_hook'
  require_dependency 'redmine_improve_custom_fields/hooks/issues_controller_hook'

  require_dependency 'redmine_improve_custom_fields/patches/field_format_numeric_patch'
  require_dependency 'redmine_improve_custom_fields/patches/field_format_base_patch'

  IssuesController.send(:include, RedmineImproveCustomFields::Patches::IssuesControllerPatch) unless IssuesController.included_modules.include? RedmineImproveCustomFields::Patches::IssuesControllerPatch
  TrackersController.send(:include, RedmineImproveCustomFields::Patches::TrackersControllerPatch) unless TrackersController.included_modules.include? RedmineImproveCustomFields::Patches::TrackersControllerPatch

  CustomFieldsHelper.send(:include, RedmineImproveCustomFields::Patches::CustomFieldsHelperPatch) unless CustomFieldsHelper.included_modules.include? RedmineImproveCustomFields::Patches::CustomFieldsHelperPatch
  IssuesHelper.send(:include, RedmineImproveCustomFields::Patches::IssuesHelperPatch) unless IssuesHelper.included_modules.include? RedmineImproveCustomFields::Patches::IssuesHelperPatch
  Journal.send(:include, RedmineImproveCustomFields::Patches::JournalPatch) unless Journal.included_modules.include? RedmineImproveCustomFields::Patches::JournalPatch
  CustomField.send(:include, RedmineImproveCustomFields::Patches::CustomFieldPatch) unless CustomField.included_modules.include? RedmineImproveCustomFields::Patches::CustomFieldPatch
  Tracker.send(:include, RedmineImproveCustomFields::Patches::TrackerPatch) unless Tracker.included_modules.include? RedmineImproveCustomFields::Patches::TrackerPatch
  Issue.send(:include, RedmineImproveCustomFields::Patches::IssuePatch) unless Issue.included_modules.include? RedmineImproveCustomFields::Patches::IssuePatch


  Redmine::FieldFormat::ListFormat.send(:include, RedmineImproveCustomFields::Patches::FieldFormatPatch) unless Redmine::FieldFormat::ListFormat.included_modules.include? RedmineImproveCustomFields::Patches::FieldFormatPatch
  Redmine::FieldFormat::FloatFormat.send(:include, RedmineImproveCustomFields::Patches::FieldFormatFloatPatch) unless Redmine::FieldFormat::FloatFormat.included_modules.include? RedmineImproveCustomFields::Patches::FieldFormatFloatPatch
  Redmine::FieldFormat::IntFormat.send(:include, RedmineImproveCustomFields::Patches::FieldFormatIntPatch) unless Redmine::FieldFormat::IntFormat.included_modules.include? RedmineImproveCustomFields::Patches::FieldFormatIntPatch



  settings default: {parent_issue_id_mode: 'normal'}, partial: 'settings/improve_custom_fields'
end
