class ImportIssueUploaderMailer < Mailer
  include Redmine::I18n
  layout 'mailer'

  def notify_success(user, saved_issues)
    @saved_issues = saved_issues
    mail to: user.mail, subject: t('import_issue_upload_finish')
  end
end
