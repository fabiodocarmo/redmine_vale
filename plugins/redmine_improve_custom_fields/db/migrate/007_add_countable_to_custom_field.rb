class AddCountableToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :countable, :boolean, default: false
  end
end
