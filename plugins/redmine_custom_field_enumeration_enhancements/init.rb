Redmine::Plugin.register :redmine_custom_field_enumeration_enhancements do
  name 'Redmine Custom Field Enumaration Enhancements plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  CustomFieldEnumeration.send(:include, RedmineCustomFieldEnumerationEnhancements::Patches::CustomFieldEnumerationPatch) unless CustomFieldEnumeration.included_modules.include? RedmineCustomFieldEnumerationEnhancements::Patches::CustomFieldEnumerationPatch
  Redmine::FieldFormat::EnumerationFormat.send(:include, RedmineCustomFieldEnumerationEnhancements::Patches::EnumerationFormatPatch) unless Redmine::FieldFormat::EnumerationFormat.included_modules.include? RedmineCustomFieldEnumerationEnhancements::Patches::EnumerationFormatPatch
end
