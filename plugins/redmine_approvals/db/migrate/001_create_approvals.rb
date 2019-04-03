class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.references :project
      t.references :tracker
      t.references :custom_field
      t.integer :sign
      t.text :value
      t.references :group
      t.integer :level
      t.integer :level_below
    end
    add_index :approvals, :project_id
    add_index :approvals, :tracker_id
    add_index :approvals, :custom_field_id
    add_index :approvals, :group_id
  end
end
