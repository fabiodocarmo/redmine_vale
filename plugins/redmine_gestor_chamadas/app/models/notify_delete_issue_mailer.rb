# Encoding: utf-8

class NotifyDeleteIssueMailer < Mailer
  def delete_issue_notification(issue)
    send_notification_email(I18n.t('no_confirmation_message', issue_id: issue.id), issue)
  end

  protected

  def send_notification_email(title, issue)
    @issue = issue
    mail(to: User.find(issue.author_id).mail, subject: title)
  end
end
