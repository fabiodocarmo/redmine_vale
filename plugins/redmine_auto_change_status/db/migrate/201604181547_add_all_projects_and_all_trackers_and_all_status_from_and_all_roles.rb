class AddAllProjectsAndAllTrackersAndAllStatusFromAndAllRoles < ActiveRecord::Migration
  def change
    add_column :auto_change_statuses, :all_projects   , :boolean
    add_column :auto_change_statuses, :all_trackers   , :boolean
    add_column :auto_change_statuses, :all_status_from, :boolean
    add_column :auto_change_statuses, :all_roles      , :boolean
  end
end
