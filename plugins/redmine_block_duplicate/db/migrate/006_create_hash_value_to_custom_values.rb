class CreateHashValueToCustomValues < ActiveRecord::Migration
  def change
    add_column :custom_values, :value_hashed, :text
  end
end
