class AddCustomMaskToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :custom_mask, :string
  end
end
