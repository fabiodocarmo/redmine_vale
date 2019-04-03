class AddTrackerIdIndexToWorkflows < ActiveRecord::Migration
  def change
    add_index :workflows, :tracker_id
  end
end
