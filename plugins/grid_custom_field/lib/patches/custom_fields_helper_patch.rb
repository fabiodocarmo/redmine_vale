module Patches

  module CustomFieldsHelperPatch

    def self.included(base) # :nodoc

      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def grid_field_tag_name(prefix, custom_field)
        prefix = prefix.to_s.split('_').collect{|p| '['+p + ']'}.join()
        name = "issue[custom_field_values]#{prefix}[#{custom_field.id}]"
        name << "[]" if custom_field.multiple?
        name
      end

      def grid_field_tag_id(prefix, custom_field)
        "issue_custom_field_values_#{prefix}_#{custom_field.id}"
      end

      # Return custom field html tag corresponding to its format
      def grid_field_tag(prefix, custom_value)
        custom_value.custom_field.format.edit_tag self,
        grid_field_tag_id(prefix, custom_value.custom_field),
          grid_field_tag_name(prefix, custom_value.custom_field),
          custom_value,
          :class => "#{custom_value.custom_field.field_format}_cf"
      end
    end
  end

end
