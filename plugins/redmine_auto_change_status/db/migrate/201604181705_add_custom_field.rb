class AddCustomField < ActiveRecord::Migration
  def change
    add_column :auto_change_statuses, :use_custom_field   , :boolean
    add_column :auto_change_statuses, :custom_field_id, :integer, index: true
    add_column :auto_change_statuses, :custom_field_value, :string
  end
end
