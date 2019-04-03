# encoding: utf-8
class ExportReportMailer < Mailer
  include Redmine::I18n
  layout 'mailer'

  def notify_external(user, file_name, attachment, subject)
    # attachments[file_name] = {
    #   :content => attachment,
    #   :mime_type => "application/vnd.ms-excel"
    # }
    # xlsx = render_to_string formats: [:xlsx], :template "export_report_mailer/export", locals: {data: attachment}
   attachments["Users.xlsx"] = {mime_type: Mime::XLSX, content: xlsx}
    # attachments[file_name] = attachment.flush.string
    mail to: user.mail, subject: subject
  end
end
