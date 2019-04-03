class CalculateValueBaseWithIvaJob < ExecJob
  unloadable

  def perform(issue)
    grid_values = grid_json_to_hash(issue)

    issue.custom_field_values = {
      config[:po_iva_grid_custom_field] => new_grid_values(grid_values)
    }
  end

  def grid_json_to_hash(issue)
    JSON.parse(
      issue.custom_value_for(config[:po_grid_custom_field])
           .value.gsub('=>', ':')
    )
  end

  def new_grid_values(grid_values)
    grid_values.map do |key, values|
      [
        key,
        fetch_new_grid_value(values)
      ]
    end.to_h
  rescue
    {}
  end

  def fetch_new_grid_value(row)
    query = build_query(row)
    erp_data = ExternalErpDataResource.erp_data(query)

    iva = erp_data[config[:iva_column_api]]
    iva_value = calc_value(row[config[:value_column]], iva)

    row.merge(
      config[:iva_item_column] => row[config[:item_column]],
      config[:iva_po_column] => row[config[:po_column]],
      config[:iva_value_column] => iva_value,
      config[:iva_column] => iva
    )
  end

  def build_query(row)
    {
      config[:po_column_api] => row[config[:po_column]],
      config[:item_column_api] => row[config[:item_column]]
    }
  end

  def calc_value(value, iva)
    value.to_f * multiply_from_iva(iva)
  end

  def multiply_from_iva(iva)
    lv = LookupTableValue.perform_lookup(config[:lookup_table_name], {
      config[:lookup_iva_column] => iva
    }, config[:lookup_value_column]).first

    lv.nil? ? 1 : lv.column_value.to_f
  end

  def self.schema
    {
      po_grid_custom_field: issue_custom_field_schema,
      po_iva_grid_custom_field: issue_custom_field_schema,
      item_column: issue_custom_field_schema,
      iva_item_column: issue_custom_field_schema,
      item_column_api: string_field_schema,
      po_column: issue_custom_field_schema,
      iva_po_column: issue_custom_field_schema,
      po_column_api: string_field_schema,
      iva_value_column: issue_custom_field_schema,
      value_column: issue_custom_field_schema,
      iva_column_api: string_field_schema,
      iva_column: issue_custom_field_schema,
      lookup_table_name: string_field_schema,
      lookup_iva_column: string_field_schema,
      lookup_value_column: string_field_schema
    }
  end
end
