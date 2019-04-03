class AddBigSizeToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :big_size, :boolean, default: false
  end
end
