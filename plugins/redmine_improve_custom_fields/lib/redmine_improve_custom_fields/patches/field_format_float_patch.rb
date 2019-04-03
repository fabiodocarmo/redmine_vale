module RedmineImproveCustomFields

  module Patches
    module FieldFormatFloatPatch
      def self.included(base) # :nodoc
        base.send(:include, ActionView::Helpers::NumberHelper)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def formatted_value(view, custom_field, value, customized=nil, html=false)
          locale = User.current.language.blank? ? I18n.locale : User.current.language
          number_with_precision value, locale: locale, precision: 2
        end

        def convert_value(custom_field, value)
          value = super(custom_field, value)

          if !separator.nil?
            value = value.gsub(separator,'.')
          end

          value
        end

      end
    end
  end
end
