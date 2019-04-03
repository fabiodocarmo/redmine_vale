class AddFreesValueAndReconcilesValueToTracker < ActiveRecord::Migration
  def change
    add_column :trackers, :frees_value     , :boolean, default: false
    add_column :trackers, :reconciles_value, :boolean, default: false
  end
end
