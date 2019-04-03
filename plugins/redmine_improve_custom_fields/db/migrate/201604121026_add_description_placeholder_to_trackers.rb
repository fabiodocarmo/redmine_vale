class AddDescriptionPlaceholderToTrackers < ActiveRecord::Migration
  def change
    add_column :trackers, :description_placeholder, :text
  end
end
