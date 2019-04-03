class AddColumnsToExternalValidation < ActiveRecord::Migration
  def change
    add_column :external_validation_queries, :column_grid_id, :integer
    add_column :external_validation_roles, :column_grid_id, :integer
  end
end
