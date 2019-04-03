class EmailToNfMailer < Mailer
  include Redmine::I18n
  layout 'mailer'

  def notify_receipt(email, issue)
    @user = User.find_by_mail(email)
    @issue = issue

    mail to: email, subject: t('xml_to_nf.mailer.notify_receipt', issue_id: issue.id)
  end

  def notify_failed_receipt(email, issue)
    @user = User.find_by_mail(email)
    @issue = issue

    mail to: email, subject: t('xml_to_nf.mailer.notify_failed_receipt')
  end
end
