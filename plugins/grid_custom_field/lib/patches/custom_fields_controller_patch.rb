module Patches
  module CustomFieldsControllerPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        base.send(:include, InstanceMethods)
        before_filter :set_grid_columns_position, :only => [:update, :create], :if => '@custom_field.field_format == Patches::FieldFormatPatch::GridFormat.name_id'
      end
    end

    module InstanceMethods
      def set_grid_columns_position
        saved_grid_columns = @custom_field.custom_fields_grid_columns
        custom_fields_grid_columns_to_update = []
        ordered_grid_columns = []
        grid_columns = params[:custom_field].delete(:grid_column_ids)
        return nil if grid_columns.blank?
        grid_columns.each_with_index do |grid_column, i|
          hash = {grid_column_id:grid_column, position:i}
          saved_grid_column = saved_grid_columns.detect{|k| k.grid_column_id == grid_column.to_i}
          if saved_grid_column && saved_grid_column.id
            hash[:id] = saved_grid_column.id
            custom_fields_grid_columns_to_update << saved_grid_column
          end
          ordered_grid_columns << hash
        end

        grid_columns_to_delete = saved_grid_columns - custom_fields_grid_columns_to_update
        if !grid_columns_to_delete.blank?
          grid_columns_to_delete.each do |g|
            hash = {id:g.id, _destroy: '1'}
            ordered_grid_columns << hash
          end
        end
        params[:custom_field][:custom_fields_grid_columns_attributes] = ordered_grid_columns
      end
    end
  end
end
