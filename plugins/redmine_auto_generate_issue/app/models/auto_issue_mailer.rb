class AutoIssueMailer < Mailer
  layout 'mailer'

  def notify_attachment_relationship(issue_id, assigned_to_id, issues_ids)
    @assigned_to    = Principal.find(assigned_to_id)
    @issue          = Issue.find(issue_id)
    @related_issues = Issue.where(id: issues_ids)

    emails = @assigned_to.is_a?(Group) ? @assigned_to.users.map(&:mail) : [@assigned_to.mail]

    mail to: emails, subject: "[#{@issue.project.name} - #{@issue.tracker.name} ##{@issue.id}] (#{@issue.status.name}) #{@issue.subject}"
  end
end
