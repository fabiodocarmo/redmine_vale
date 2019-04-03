class SqlReportMailer < Mailer
  include Redmine::I18n
  layout 'mailer'

  def notify_external(execution)
    user, sql_report, file_name = execution.requester, execution.sql_report, execution.file_name
    attachments[file_name] = File.read("#{SQL_REPORT_ROOT_DIRECTORY}/#{file_name}")
    mail to: user.mail, subject: sql_report.name
  end
end
