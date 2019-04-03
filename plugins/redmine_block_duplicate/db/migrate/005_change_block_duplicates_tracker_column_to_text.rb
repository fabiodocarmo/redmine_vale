class ChangeBlockDuplicatesTrackerColumnToText < ActiveRecord::Migration
  def change
    change_column(:block_duplicates, :tracker_id, :text)
  end
end
