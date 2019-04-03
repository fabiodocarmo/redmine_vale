module RedmineExternalValidation
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          after_save :find_external_validation_status
          after_commit :exec_validation
        end
      end

      module ClassMethods; end

      module InstanceMethods

        def find_external_validation_status
          @find_external_validation_status = ExternalValidation.find_by_issue(self)
        end

        def exec_validation
          user = Setting.plugin_redmine_external_validation['user'].to_i
          user = User.current.id if user.zero?

          @find_external_validation_status ||= ExternalValidation.none
          @find_external_validation_status.each do |ev|
            AsyncExternalValidation.perform_later(user, id, ev.id, 0)
          end
        end
      end
    end
  end
end
