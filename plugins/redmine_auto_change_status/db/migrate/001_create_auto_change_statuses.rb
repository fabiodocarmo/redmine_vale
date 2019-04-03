class CreateAutoChangeStatuses < ActiveRecord::Migration
  def change
    create_table :auto_change_statuses do |t|
      t.integer :project_id
      t.integer :tracker_id
      t.integer :status_from_id
      t.integer :status_to_id
      t.integer :role_id
      t.string :action
    end
  end
end
