class SlaMailer < Mailer
  include Redmine::I18n
  layout 'mailer'

  def notify_overdue(user, issue)
    @user = user
    @issue = issue

    set_language_if_valid(user.language)

    mail to: user.mail, subject: t('sla.mailer.notify_overdue_title', issue.id, issue.subject)
  end

  def notify_inactivity(user, issue)
    @user = user
    @issue = issue

    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)

    set_language_if_valid(user.language)

    mail to: user.mail, subject: t('sla.mailer.notify_inactivity_title', issue.id, issue.subject)
  end

  def notify_open_time(user, issue)
    @user = user
    @issue = issue

    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)

    set_language_if_valid(user.language)

    mail to: user.mail, subject: t('sla.mailer.notify_open_time_title', issue.id, issue.subject)
  end
end
