class AddEmailOnlyInClosedStatus < ActiveRecord::Migration
  def change
    add_column :trackers, :email_only_in_closed_status, :boolean
  end
end
