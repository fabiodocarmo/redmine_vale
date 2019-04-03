module RedmineImproveCustomFields

  module Patches
    module FieldFormatNumericPatch
      def self.included(base) # :nodoc
        base.send(:include, ActionView::Helpers::NumberHelper)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods

        def edit_tag(view, tag_id, tag_name, custom_value, options={})
          value = formatted_value(view, custom_value.custom_field, custom_value.value)
          view.text_field_tag(tag_name, value, options.merge(:id => tag_id))
        end

        def convert_value(custom_field, value)
          if !delimiter.nil?
            value = value.gsub(delimiter, '')
          end
          value
        end

        protected

        def delimiter
          @delimiter ||= I18n::t('number.format.delimiter')
        end

        def separator
          @separator ||= I18n::t('number.format.separator')
        end


      end
    end
  end
end

Redmine::FieldFormat::Numeric.send(:include, RedmineImproveCustomFields::Patches::FieldFormatNumericPatch) unless Redmine::FieldFormat::Numeric.included_modules.include? RedmineImproveCustomFields::Patches::FieldFormatNumericPatch
