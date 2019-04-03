class AddDontCopyToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :dont_copy, :boolean, default: false
  end
end
