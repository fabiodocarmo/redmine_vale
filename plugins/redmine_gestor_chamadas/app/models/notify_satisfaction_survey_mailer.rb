# Encoding: utf-8

class NotifySatisfactionSurveyMailer < Mailer
  def satisfaction_survey_notification(issue)
    @issue = issue

    previous_language = current_language

    set_language_if_valid issue.author.language
    mail_to_send = mail(to: issue.author.mail, subject: I18n.t('satisfaction_survey_mail_title', issue_id: issue.id))
    set_language_if_valid previous_language
    mail_to_send
  end

end
