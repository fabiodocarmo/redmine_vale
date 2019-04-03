module RedmineImproveCustomFields
  module Hooks
    class IssuesControllerHook < Redmine::Hook::ViewListener
      def controller_issues_new_before_save(context={ })
        @issue   = context[:issue]
        return if !@issue || !@issue.tracker_id

        @tracker = Tracker.includes(improvecf_group_priorities: [:author, :enumeration]).find(@issue.tracker_id)

        if new_priority = @tracker.improvecf_group_priorities.select { |gp| User.current.in?(gp.author.users) }.sort(&:enumeration_id).last.try(&:enumeration)
          @issue.priority = new_priority
        end
      end
    end
  end
end
