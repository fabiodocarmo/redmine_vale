Redmine::Plugin.register :label_custom_field do
  name 'Label Custom Field plugin'
  author 'Visagio'
  description 'This plugin enables to create custom fields of type label'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'


  require 'label_custom_field/patches/field_format_patch'
  require 'label_custom_field/patches/custom_value_patch'
  require 'label_custom_field/hooks/settings_label_hook_listener'

  CustomValue.send(:include, LabelCustomFieldPatches::CustomValuePatch) unless CustomValue.included_modules.include?(LabelCustomFieldPatches::CustomValuePatch)

end
