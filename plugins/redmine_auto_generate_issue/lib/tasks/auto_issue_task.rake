namespace :redmine do
  namespace :plugins do
    namespace :auto_issue do
      task :generate_schedule_issues => :environment do
        # if you use cron, the better way to run this is putting at midnight
        AutoIssueScheduleTrigger.where('datetime_trigger = DATE(?)', Time.zone.now.to_date).each do |trigger|
          if Redmine::VERSION::MAJOR >= 3
            TriggerJob.set(wait: ([trigger.hour - Time.zone.now.hour, 0].max).hours).perform_later(AutoIssueScheduleTrigger.to_s, trigger.id)
          else
            begin
              trigger.build_issue.save(validate: false)
            rescue Exception => e
              Rails.logger.error(e)
            end
          end
        end
      end

      task :generate_recurrent_issues => :environment do
        AutoIssueRecurrentTrigger.where("DATEDIFF(?, base_date)%each_day = 0 and active = true", Time.zone.now.to_date).each do |trigger|
          if Redmine::VERSION::MAJOR >= 3
            TriggerJob.set(wait: ([trigger.hour - Time.zone.now.hour, 0].max).hours).perform_later(AutoIssueScheduleTrigger.to_s, trigger.id)
          else
            begin
              trigger.build_issue.save(validate: false)
            rescue Exception => e
              Rails.logger.error(e)
            end
          end
        end
      end
    end
  end
end
