class AddMaskToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :mask, :string
  end
end
