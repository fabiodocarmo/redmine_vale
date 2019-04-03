class CreateAutoIssueScheduleTriggers < ActiveRecord::Migration
  def change
    create_table :auto_issue_schedule_triggers do |t|
      t.integer :schedule_auto_issue_id
      t.datetime :datetime_trigger
    end
  end
end
