module RedmineApiIntegrations
  module Patches
    module JournalPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          alias_method_chain :send_notification, :email_blocker
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def send_notification_with_email_blocker
          issue = Issue.find(self.journalized_id)
          if ApiIntegration.tracker_exists(issue.tracker_id) and ApiIntegration.find_project_id_by_tracker(issue.tracker_id) == issue.project_id
            MailerModel.deliver_issue_edit(self)
          else
            send_notification_without_email_blocker
          end
        end
      end
    end
  end
end
