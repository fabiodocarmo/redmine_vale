class AddCallbackNameToExecJobs < ActiveRecord::Migration
  def change
    add_column :exec_jobs, :callback_name, :string, default: 'after_commit'
  end
end
