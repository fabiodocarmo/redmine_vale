module RedmineAutoChangeStatus
  module Patches
    # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
    module IssuesControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_render :verify_status_change_by_open
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def verify_status_change_by_open
          return unless action_name == "show"
          return unless @issue

          if auto_change_status = AutoChangeStatus.find_by_issue(@issue).where(action: :open).first
            @issue.status = auto_change_status.status_to
            @issue.save(validate: false)
            @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
          end
        end
      end

    end
  end
end
