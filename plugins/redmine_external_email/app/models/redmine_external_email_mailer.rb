class RedmineExternalEmailMailer < Mailer
  include Redmine::I18n
  layout 'mailer'

  def notify_external(issue, external_notification)
    @external_notification = external_notification

    if @external_notification.send_attachments?
      issue.attachments.each do |a|
        attachments[a.filename] = File.read(a.diskfile)
      end
    end

    mail to: issue.custom_field_value(external_notification.email_custom_field_id), subject: external_notification.subject
  end

end
