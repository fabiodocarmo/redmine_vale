module RedmineApprovals
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          before_save :verify_approval_is_required
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def verify_approval_is_required
          assigned_to_id, status_id = Approval.verify_approval_is_required(self)

          self.assigned_to_id = assigned_to_id if assigned_to_id
          self.status_id      = status_id      if status_id
        end
      end
    end
  end
end
