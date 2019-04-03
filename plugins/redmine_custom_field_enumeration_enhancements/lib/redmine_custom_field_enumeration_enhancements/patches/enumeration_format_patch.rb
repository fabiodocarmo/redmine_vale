module RedmineCustomFieldEnumerationEnhancements
  module Patches
    module EnumerationFormatPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          alias_method_chain :possible_values_options, :key
          alias_method_chain :value_from_keyword     , :key
          alias_method_chain :cast_single_value      , :key
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def possible_values_options_with_key(custom_field, object=nil)
          possible_values_records(custom_field, object).map { |u| [u.name, u.key.blank? ? u.id.to_s : u.key] }
        end

        def value_from_keyword_with_key(custom_field, keyword, object)
          value = custom_field.enumerations.where("LOWER(name) LIKE LOWER(?)", keyword).first
          value ? (value.key.blank? ? value.id : value.key) : nil
        end

        def cast_single_value_with_key(custom_field, value, customized=nil)
          if value.present?
            single_value = target_class.find_by_key_and_custom_field_id(value, custom_field.id)

            unless single_value
              single_value = target_class.find_by_id_and_custom_field_id(value.to_i, custom_field.id)
            end

            single_value
          end
        end
      end
    end
  end
end
