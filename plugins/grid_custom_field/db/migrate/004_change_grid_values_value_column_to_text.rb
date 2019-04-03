class ChangeGridValuesValueColumnToText < ActiveRecord::Migration
  def change
    change_column(:grid_values, :value, :text)
  end
end
