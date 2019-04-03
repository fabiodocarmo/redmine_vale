module GestorChamadas
  module ContextMenusControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :issues, :disabled_archived_edit
      end
    end

    module InstanceMethods
      def issues_with_disabled_archived_edit(user=User.current)
        if @issues.any? {|t| !t.editable_with_disabled_archived_edit?}
          if (@issues.size == 1)
            @issue = @issues.first
          end
          @issue_ids = @issues.map(&:id).sort

          @allowed_statuses = @issues.map(&:new_statuses_allowed_to).reduce(:&)

          @can = {:edit => false,
                  :log_time => (@project && User.current.allowed_to?(:log_time, @project)),
                  :copy => User.current.allowed_to?(:copy_issues, @projects) && Issue.allowed_target_projects.any?,
                  :delete => User.current.allowed_to?(:delete_issues, @projects)
                  }
          if @project
            if @issue
              @assignables = @issue.assignable_users
            else
              @assignables = @project.assignable_users
            end
            @trackers = @project.trackers
          else
            #when multiple projects, we only keep the intersection of each set
            @assignables = @projects.map(&:assignable_users).reduce(:&)
            @trackers = @projects.map(&:trackers).reduce(:&)
          end
          @versions = @projects.map {|p| p.shared_versions.open}.reduce(:&)

          @priorities = IssuePriority.active.reverse
          @back = back_url

          @options_by_custom_field = {}

          @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)
          render :layout => false
        else
          issues_without_disabled_archived_edit
        end
      end
    end
  end
end
