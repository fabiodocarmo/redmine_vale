class CreateExternalValidations < ActiveRecord::Migration
  def change
    create_table :external_validations do |t|
      t.integer :project_id
      t.boolean :all_projects
      t.integer :tracker_id
      t.boolean :all_trackers
      t.integer :status_from_id
      t.boolean :all_status_from
      t.integer :status_to_id

      t.integer :success_status_id
    end
  end
end
