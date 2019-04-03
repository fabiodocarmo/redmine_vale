module Localizable
  module Patches
    module CustomFieldsHelperPatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :show_value, :localizable
        end
      end

      module InstanceMethods
        include TranslateHelper
        # Return a string used to display a custom value
        def show_value_with_localizable(custom_value, html=true)
          custom_value.custom_field.default_value = translate_value(custom_value.custom_field.default_value, :defaults)
          format_object(custom_value, html)
        end
      end
    end
  end
end
