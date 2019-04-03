class CreateRelationTableGridCustomField < ActiveRecord::Migration
  def change
    create_table :custom_fields_grid_columns do |t|
      t.integer :grid_column_id
      t.integer :custom_field_id
      t.integer :position
    end
    #TODO: COLOCAR INDICE DE UNIQUE: add_index(:apples_oranges, [:apple_id, :orange_id], :unique => true)
  end
end
