class CreateAutoIssueRecurrentTriggers < ActiveRecord::Migration
  def change
    create_table :auto_issue_recurrent_triggers do |t|
      t.integer :recurrent_auto_issue_id, index: true
      t.date :base_date
      t.integer :each_day
    end
  end
end
