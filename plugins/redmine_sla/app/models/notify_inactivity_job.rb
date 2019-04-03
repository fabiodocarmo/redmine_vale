class NotifyInactivityJob < ActiveJob::Base
  queue_as :sla

  def perform(issue_id, notify_author, notify_assign_to, notify_group, group_id, updated_on)
    issue = Issue.find(issue_id)
    return if issue.updated_on > Time.parse(updated_on) || issue.closed?


    if notify_author && issue.author
      notify(issue, issue.author)
    end

    assigned_to = issue.assigned_to
    if notify_assign_to && assigned_to
      if assigned_to.is_a? Group
        assigned_to.users.find_each do |u|
          notify(issue, u)
        end
      else
        notify(issue, assigned_to)
      end
    end

    if notify_group
      if group = Group.where(id: group_id).first
        group.users.find_each do |u|
          notify(issue, u)
        end
      end
    end
  end

  private

  def notify(issue, user)
    SlaMailer.notify_inactivity(user, issue).deliver if user
  end
end
