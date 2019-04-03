class AddHoursToTrigger < ActiveRecord::Migration
  def change
    add_column :auto_issue_recurrent_triggers, :hour, :integer, default: 0

    add_column :auto_issue_schedule_triggers, :hour, :integer, default: 0
  end
end
