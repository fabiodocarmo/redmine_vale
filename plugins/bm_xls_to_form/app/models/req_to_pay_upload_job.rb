class ReqToPayUploadJob < ActiveJob::Base
  queue_as :req_to_pay

  def perform(attachment_id, user_id)
    updated_ids = ReqToPayProcessing.update_by_req_to_pay(attachment_id) || []
    ReqToPayUploaderMailer.notify_success(User.find(user_id), updated_ids).deliver
  end
end
