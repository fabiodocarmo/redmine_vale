module Localizable
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :editable_custom_field_values, :localizable
        end
      end

      module ClassMethods; end


      module InstanceMethods
        include TranslateHelper
        # Returns the custom_field_values that can be edited by the given user
        def editable_custom_field_values_with_localizable(user=nil)
          visible_values = visible_custom_field_values(user).reject do |value|
            read_only_attribute_names(user).include?(value.custom_field_id.to_s)
          end
          find_and_translate_values(visible_values)
          visible_values
        end

        def find_and_translate_values(values)
          values.each do |v|
            v.custom_field.description = translate_value(v.custom_field.description, :descriptions)
            v.custom_field.default_value = translate_value(v.custom_field.default_value, :defaults)
          end
        end
      end
    end
  end
end
