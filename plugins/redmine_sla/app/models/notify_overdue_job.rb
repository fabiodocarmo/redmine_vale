class NotifyOverdueJob < ActiveJob::Base
  queue_as :sla

  def perform(issue_id, notify_overdue_hour, notify_overdue_author, notify_overdue_assign_to, notify_group, group_id)
    issue = Issue.find(issue_id)

    assigned_to = issue.assigned_to

    if notify_overdue_assign_to && assigned_to
      if assigned_to.is_a? Group
        assigned_to.users.find_each do |u|
          notify(issue, u, notify_overdue_hour)
        end
      else
        notify(issue, assigned_to, notify_overdue_hour)
      end
    end

    if notify_overdue_author && issue.author
      notify(issue, issue.author, notify_overdue_hour)
    end

    if notify_group
      if group = Group.where(id: group_id).first
        group.users.find_each do |u|
          notify(issue, u, notify_overdue_hour)
        end
      end
    end
  end

  private

  def notify(issue, user, notify_overdue_hour)
    if issue.sla_overdue?(user, notify_overdue_hour)
      SlaMailer.notify_overdue(user, issue).deliver
    end
  end
end
