class AddIndex < ActiveRecord::Migration
  def change
    add_index :dependent_fields, [:project_id, :tracker_id, :dependent_type], name: "dependent_fields_project_tracker_type"
  end
end
