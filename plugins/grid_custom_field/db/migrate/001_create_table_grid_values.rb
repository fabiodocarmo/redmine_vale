class CreateTableGridValues < ActiveRecord::Migration
  def change
    create_table :grid_values do |t|
      t.references :custom_value
      t.integer :row
      t.integer :column
      t.string :value
    end
  end
end
