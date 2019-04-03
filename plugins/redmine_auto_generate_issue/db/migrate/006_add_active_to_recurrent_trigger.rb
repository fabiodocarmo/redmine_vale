class AddActiveToRecurrentTrigger < ActiveRecord::Migration
  def change
    add_column :auto_issue_recurrent_triggers, :active, :boolean
  end
end
