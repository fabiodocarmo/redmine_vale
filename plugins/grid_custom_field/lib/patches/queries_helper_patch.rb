module Patches
  module QueriesHelperPatch

    def self.included(base) # :nodoc
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :query_to_csv, :grid
      end
    end

    module InstanceMethods

      def query_to_csv_with_grid(items, query, options={})
        encoding = l(:general_csv_encoding)
        options ||= {}
        columns = (options[:columns] == 'all' ? query.available_inline_columns : query.inline_columns)
        query.available_block_columns.each do |column|
          if options[column.name].present?
            columns << column
          end
        end
        if Redmine::VERSION::MAJOR >= 3
          export = Redmine::Export::CSV.generate { |csv| generate_csv(csv, columns, encoding, items) }
        else
          export = FCSV.generate(:col_sep => l(:general_csv_separator)) { |csv| generate_csv(csv, columns, encoding, items) }
        end
        export
      end

      def generate_csv(csv, columns, encoding, items)
        csv << build_header(columns, encoding)

        items.each do |item|
          generate_rows(columns, encoding, item).each do |row|
            csv << row
          end
        end
      end

      private

      def build_header(columns, encoding)
        columns.map do |c|
          if !(c.is_a? QueryCustomFieldColumn) || c.custom_field.field_format != "grid"
            c.caption.to_s
          else
            c.custom_field.sorted_grid_columns.map do |grid_column|
              Redmine::CodesetUtil.from_utf8(c.custom_field.name + " [" + grid_column.name.to_s + "]", encoding)
            end
          end
        end.flatten
      end

      def generate_rows(columns, encoding, item)
        max_rows = fetch_max_rows(columns, item)

        grid_custom_values = fetch_grid_custom_values(columns, item)

        (1..max_rows).map do |row|
          columns.map do |c|
            if !(c.is_a? QueryCustomFieldColumn) || c.custom_field.field_format != "grid"
              csv_content(c, item)
            else
              grid_values = grid_custom_values[c][row - 1]

              if grid_values
                c.custom_field.sorted_grid_columns.map do |grid_column|
                  grid_column_value = grid_values.select { |gv| gv.column == grid_column.id }
                  Redmine::CodesetUtil.from_utf8(csv_value(c, item, grid_column_value.length > 0 ? grid_column_value.first.value : ""), encoding).gsub(/\n|\r/, " ")
                end
              else
                c.custom_field.sorted_grid_columns.map do |grid_column|
                  ""
                end
              end
            end
          end.flatten
        end
      end

      def query_grid_columns(columns)
        @query_grid_columns ||= columns.select { |c| c.is_a?(QueryCustomFieldColumn) && c.custom_field.field_format == "grid" }
      end

      def fetch_max_rows(columns, item)
        max_rows = query_grid_columns(columns).map { |c| c.value_object(item).try(:rows_count) || 1 }.max
        max_rows = max_rows ? [1, max_rows].max : 1
      end

      def fetch_grid_custom_values(columns, item)
        query_grid_columns(columns).reduce({}) do |acc, c|
          acc[c] = (custom_value = c.value_object(item)) ? custom_value.grid_values.order('row ASC').group_by(&:row).map { |row, values| values } : []
          acc
        end
      end
    end
  end
end
