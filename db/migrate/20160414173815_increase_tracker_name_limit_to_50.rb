class IncreaseTrackerNameLimitTo50 < ActiveRecord::Migration
  def change
    change_column :trackers, :name, :string, limit: 50
  end
end
