class ChangeDatetimeTriggerToDate < ActiveRecord::Migration
  def change
    change_column :auto_issue_schedule_triggers, :datetime_trigger, :date
  end
end
