class CreateAutoIssueAttachmentTriggers < ActiveRecord::Migration
  def change
    create_table :auto_issue_attachment_triggers do |t|
      t.integer :attachment_auto_issue_id

      t.integer :project_id
      t.integer :tracker_id
      t.integer :status_id
    end
  end
end
