class AsyncStatusChange < ActiveJob::Base
  queue_as :status_change

  def perform(issue_id)
    issue = Issue.find(issue_id)
    if issue.status_id == Setting.plugin_recebimento_fiscal_vale[:status_change][:old_status_id].to_i
      issue.status_id = Setting.plugin_recebimento_fiscal_vale[:status_change][:status_id]
      issue.save
    end
  end
end
