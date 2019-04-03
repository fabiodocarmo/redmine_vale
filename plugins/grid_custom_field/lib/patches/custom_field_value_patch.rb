module Patches
  module CustomFieldValuePatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      delegate :format, to: :custom_field
    end

    module InstanceMethods
      def grid_values
        custom_value = CustomValue.where(customized_id:customized).where(custom_field_id:custom_field_id).first
        return nil if custom_value.blank?
        custom_value.grid_values.includes(:custom_value).includes(custom_value:'custom_field')
          .includes(custom_value:{custom_field:'grid_columns'})
          .order('grid_values.row ASC').order('grid_columns_custom_fields.position ASC')
      end

      def rows_count
        custom_value = CustomValue.where(customized_id:customized).where(custom_field_id:custom_field_id).first
        return nil if custom_value.blank?
        custom_value.grid_values.select('distinct row').count
      end

      def value_blank?
        format.value_blank?(self.value)
      end
    end
  end
end
