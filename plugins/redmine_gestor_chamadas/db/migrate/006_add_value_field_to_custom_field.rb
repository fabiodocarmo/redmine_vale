class AddValueFieldToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :value_field, :boolean, default: false
  end
end
