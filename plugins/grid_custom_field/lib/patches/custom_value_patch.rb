module Patches
  module CustomValuePatch
    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        has_many :grid_values, dependent: :destroy
        before_save :set_grid_values_from_value, if: 'custom_field.format.is_a? Patches::FieldFormatPatch::GridFormat'
      end
    end

    def set_grid_values_from_value
      self.grid_values = set_grid_values_from_hash(self.value)
    end

    def set_grid_values_from_hash(hash_as_string)
      return [] if hash_as_string.blank?
      grid_values_list = []
      hash = JSON.parse hash_as_string.gsub('=>',':')
      hash.each do |row_index,cells|
        cells.each do |column_index,cell|
          #TODO: Usar as linhas comentadas abaixo para fazer update e não precisar salvar nova linha sempre.Ainda não está assim pois está dando problema para reconhecer que mudou apenas o valor
          #grid_value = self.grid_values.detect {|gv| gv.row == row_index.to_i && gv.column == column_index.to_i}
          #grid_value.value = cell if grid_value
          grid_value = GridValue.new(column:column_index, row:row_index, value:cell)
          grid_values_list << grid_value
        end
      end
      grid_values_list
    end

    def sorted_grid_values
      @sorted_grid_values ||= GridValue.joins('INNER JOIN custom_values on custom_value_id = custom_values.id')
                                       .joins('INNER JOIN custom_fields on custom_fields.id = custom_values.custom_field_id')
                                       .joins('INNER JOIN custom_fields_grid_columns on custom_fields.id = custom_fields_grid_columns.custom_field_id and custom_fields_grid_columns.grid_column_id = grid_values.column')
                                       .where(custom_value_id: id)
                                       .order('grid_values.row ASC, custom_fields_grid_columns.position ASC')
    end

    def rows_count
      grid_values.select('distinct row').count
    end

  end
end
