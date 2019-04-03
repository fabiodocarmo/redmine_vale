class AddFlagDisplaySubprojectTrackersToProject < ActiveRecord::Migration
  def change
    add_column :projects, :display_subprojects_trackers, :boolean, null: true

    Project.update_all(display_subprojects_trackers: true)
  end
end
