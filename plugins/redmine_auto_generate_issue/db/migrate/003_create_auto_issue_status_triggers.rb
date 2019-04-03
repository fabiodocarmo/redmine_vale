class CreateAutoIssueStatusTriggers < ActiveRecord::Migration
  def change
    create_table :auto_issue_status_triggers do |t|
      t.integer :status_auto_issue_id

      t.integer :project_id
      t.integer :tracker_id
      t.integer :status_from_id
      t.integer :status_to_id
    end
  end
end
