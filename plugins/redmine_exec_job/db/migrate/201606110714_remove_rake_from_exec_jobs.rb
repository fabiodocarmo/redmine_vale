class RemoveRakeFromExecJobs < ActiveRecord::Migration
  def up
    remove_column :exec_jobs, :rake_path
    remove_column :exec_jobs, :rake_task_name
    remove_column :exec_jobs, :rake_args

    add_column :exec_jobs, :type, :string
  end

  def down
    add_column :exec_jobs, :rake_path, :string
    add_column :exec_jobs, :rake_task_name, :string
    add_column :exec_jobs, :rake_args, :string

    remove_column :exec_jobs, :type, :string
  end
end
