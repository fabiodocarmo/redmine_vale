class AddHideLabelToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :hide_label, :boolean, default: false
  end
end
