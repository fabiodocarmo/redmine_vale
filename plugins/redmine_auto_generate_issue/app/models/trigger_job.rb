class TriggerJob < ActiveJob::Base
  queue_as :auto_issue

  def perform(class_name, trigger_id)
    class_name.constantize.find(trigger_id).build_issue.save(validate: false)
  end
end
