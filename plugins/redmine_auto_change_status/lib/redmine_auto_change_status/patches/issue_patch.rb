module RedmineAutoChangeStatus
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          before_save :update_my_status
          after_commit  :update_issue_relation
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def update_my_status
          return unless project

          if (auto_change_status = AutoChangeStatus.find_by_issue(self).where(action: :save).first)
            self.status = auto_change_status.status_to
            update_closed_on
          end
        end

        def update_issue_relation
          relations_to.map(&:issue_from).each do |issue|
            if (auto_change_status = AutoChangeStatus.find_by_issue(issue).where(action: :relation_closed).first)
              closed_relation = issue.relations_from.select { |r| r.issue_to.closed? }

              next if closed_relation.blank?

              issue.status = auto_change_status.status_to
              issue.send(:update_closed_on)

              issue.save(validate: false)
            end
          end
        end
      end

    end
  end
end
