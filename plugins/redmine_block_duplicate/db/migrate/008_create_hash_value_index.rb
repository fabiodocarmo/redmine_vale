class CreateHashValueIndex < ActiveRecord::Migration
    add_index :custom_values, :value_hashed
end
