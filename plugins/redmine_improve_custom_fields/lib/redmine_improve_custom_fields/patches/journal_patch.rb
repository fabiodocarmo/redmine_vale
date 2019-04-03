module RedmineImproveCustomFields
  module Patches
    module JournalPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :send_notification, :email_only_in_closed_status
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def send_notification_with_email_only_in_closed_status
          send_notification_without_email_only_in_closed_status if issue.status.is_closed? || !issue.tracker.email_only_in_closed_status
        end
      end
    end
  end
end
