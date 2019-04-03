module RedmineExternal
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          after_commit :send_external_notification
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def send_external_notification
          RedmineExternalEmail.find_by_issue(self).each do |external_notification|
            RedmineExternalEmailMailer.notify_external(self, external_notification).deliver
          end
        end
      end
    end
  end
end
