# encoding: UTF-8
class MailerExport < Mailer
  #content_type "multipart/mixed"

  layout 'mailer'
  helper :application
  helper :custom_fields

  def send_issues_export(attachment, user_id)
    @user = User.find(user_id)
    @password = "senha"
    attachments["issues.csv"] = {
      :content => attachment,
      :mime_type => "text/csv"
    }
    mail :to => @user.mail, :subject => l(:csv_export_mail_subject_message)
  end
end
