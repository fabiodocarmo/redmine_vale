class ReqToPayUploaderMailer < Mailer
  include Redmine::I18n
  layout 'mailer'

  def notify_success(user, updated_ids)
  	@updated_ids = updated_ids
    mail to: user.mail, subject: "Upload do Req To Pay"
  end
end