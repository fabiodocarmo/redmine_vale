class AddEmailControllerStatusTrigger < ActiveRecord::Migration
  def change
    add_column :auto_issue_status_triggers, :send_email              , :boolean, default: true
    add_column :auto_issue_status_triggers, :notify_on_previous_email, :boolean, default: false
  end
end
