module RedmineImproveCustomFields

  module Patches
    module FieldFormatPatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :edit_tag, :auto_completion
          alias_method_chain :possible_values_options, :auto_completion
        end
      end

      module InstanceMethods
        def edit_tag_with_auto_completion(view, tag_id, tag_name, custom_value, options={})
          if custom_value.custom_field.edit_tag_style == 'autocomplete'
            options[:class] += ' improvecf_list_autocomplete'
            options['data-placeholder'.to_sym] = I18n.t(:type_to_search)
          end
          select_tag = edit_tag_without_auto_completion(view, tag_id, tag_name, custom_value, options)
          select_tag = select_tag.gsub('&nbsp;', '').html_safe if custom_value.custom_field.edit_tag_style == 'autocomplete'
          select_tag
        end

        def possible_values_options_with_auto_completion(custom_field, object=nil)
          if custom_field.edit_tag_style == 'autocomplete'
            return []
          else
            possible_values_options_without_auto_completion(custom_field, object)
          end
        end
      end

    end
  end
end
