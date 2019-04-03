class CreateExecJobs < ActiveRecord::Migration
  def change
    create_table :exec_jobs do |t|
      t.integer :project_id
      t.boolean :all_projects
      t.integer :tracker_id
      t.boolean :all_trackers
      t.integer :status_from_id
      t.boolean :all_status_from
      t.integer :status_to_id

      t.string :rake_path
      t.string :rake_task_name
      t.text :rake_args
    end
  end
end
