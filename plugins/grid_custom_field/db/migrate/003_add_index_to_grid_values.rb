class AddIndexToGridValues < ActiveRecord::Migration
  def change
    add_index(:grid_values, [:custom_value_id, :column], name: 'index_gridvalues_customvalueid_column')
    add_index(:grid_values, [:custom_value_id, :row], name: 'index_gridvalues_customvalueid_row')
  end
end
