class AddDescriptionToTrackers < ActiveRecord::Migration
  def change
    add_column :trackers, :description, :text
  end
end
