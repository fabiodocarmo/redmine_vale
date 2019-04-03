class ChangeToDueStatusJob < ActiveJob::Base
  queue_as :sla

  def perform(issue_id, sla_id)
    issue = Issue.find(issue_id)
    sla   = VsgSla::Sla.find(sla_id)

    if !issue.closed? && sla.issue_statuses.to_a.include?(issue.status) && sla.calc_due_time(issue, true) < Time.zone.now
      issue.status_id = sla.due_status_id
      issue.save(validate: false)
    end
  end
end
