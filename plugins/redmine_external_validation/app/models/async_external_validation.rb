class AsyncExternalValidation < ActiveJob::Base
  queue_as :external_validation

  def perform(user_id, issue_id, external_validation_id, retry_num)
    ev = ExternalValidation.find(external_validation_id)
    ev.perform(user_id, issue_id, external_validation_id, retry_num)
  end
end
