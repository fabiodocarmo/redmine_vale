class NotifyOpenTimeJob < ActiveJob::Base
  queue_as :sla

  def perform(issue_id, notify_author, notify_assign_to, notify_group, group_id, sla_id)
    issue = Issue.find(issue_id)
    sla = VsgSla::Sla.where(id: sla_id).first
    return if issue.closed? || !sla


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

    NotifyOpenTimeJob.set(wait_until: sla.calc_date_plus_time(Time.zone.now, sla.notify_open_time_hour))
                       .perform_later(issue_id, sla.notify_open_time_author, sla.notify_open_time_assign_to, sla.notify_open_time_group, sla.open_time_group_id, sla.id)
  end

  private

  def notify(issue, user)
    SlaMailer.notify_open_time(user, issue).deliver if user
  end
end
