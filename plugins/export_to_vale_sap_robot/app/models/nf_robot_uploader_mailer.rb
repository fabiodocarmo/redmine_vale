class NfRobotUploaderMailer < Mailer
  include Redmine::I18n
  layout 'mailer'

  def notify_success(user)
    mail to: user.mail, subject: t('nf_robot_upload_finish')
  end
end
