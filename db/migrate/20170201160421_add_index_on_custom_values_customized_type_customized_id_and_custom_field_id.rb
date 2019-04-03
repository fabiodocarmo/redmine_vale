class AddIndexOnCustomValuesCustomizedTypeCustomizedIdAndCustomFieldId < ActiveRecord::Migration
  def change
    add_index :custom_values, [:customized_type, :customized_id, :custom_field_id],
              name: :index_custom_values_on_ctmz_type_and_ctmz_id_and_cf_id
    remove_index :custom_values, column: [:customized_type, :customized_id],
              name: :custom_values_customized
  end
end
