class AsyncExecJob < ActiveJob::Base
  queue_as :exec_job

  def perform(issue_id, exec_job_id)
    ExecJob.find(exec_job_id).perform(issue_id)
  end
end
