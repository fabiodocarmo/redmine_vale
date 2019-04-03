module RedmineImproveCustomFields
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module Patches
    module CustomFieldsHelperPatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :custom_field_tag_with_label, :label_control
          alias_method_chain :edit_tag_style_tag, :auto_completion
        end
      end

      module InstanceMethods
        def custom_field_tag_with_label_with_label_control(name, custom_value, options={})
          if custom_value.custom_field.hide_label
            custom_field_tag(name, custom_value)
          else
            custom_field_tag_with_label_without_label_control(name, custom_value, options)
          end
        end

        def edit_tag_style_tag_with_auto_completion(form, options={})
          select_options = [[l(:label_drop_down_list), ''], [l(:label_checkboxes), 'check_box'], [l('improve_fields.label_autocomplete'), 'autocomplete']]
          if options[:include_radio]
            select_options << [l(:label_radio_buttons), 'radio']
          end
          form.select :edit_tag_style, select_options, :label => :label_display
        end

      end
    end
  end
end
