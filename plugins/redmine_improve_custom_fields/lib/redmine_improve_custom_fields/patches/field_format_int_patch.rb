module RedmineImproveCustomFields

  module Patches
    module FieldFormatIntPatch
      def self.included(base) # :nodoc
        base.send(:include, ActionView::Helpers::NumberHelper)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        def formatted_value(view, custom_field, value, customized=nil, html=false)
          return super if custom_field.url_pattern.present?

          locale = User.current.language.blank? ? I18n.locale : User.current.language
          if Setting.try(:plugin_redmine_improve_custom_fields)[:format_integer]
            number_with_delimiter value, locale: locale
          else
            value
          end

        end
      end
    end
  end
end
