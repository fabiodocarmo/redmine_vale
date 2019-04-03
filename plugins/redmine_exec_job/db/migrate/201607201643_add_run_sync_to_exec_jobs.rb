class AddRunSyncToExecJobs < ActiveRecord::Migration
  def change
    add_column :exec_jobs, :run_sync, :boolean
  end
end
