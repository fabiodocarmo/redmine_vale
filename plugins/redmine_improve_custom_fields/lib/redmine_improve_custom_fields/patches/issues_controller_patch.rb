module RedmineImproveCustomFields
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module Patches
    module IssuesControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :build_new_issue_from_params, :empty_tracker

          skip_before_filter :build_new_issue_from_params
          before_filter :convert_custom_field_values, only: [:create, :update, :bulk_update]
          before_filter :build_new_issue_from_params, :only => [:new, :create]

        end
      end

      module ClassMethods
      end

      module InstanceMethods

        def convert_custom_field_values
          custom_field_values = params[:issue] && params[:issue][:custom_field_values]
          if custom_field_values
            custom_fields = CustomField.where(id: custom_field_values.try(&:keys))
            converted_custom_field_values = custom_field_values.map do |cf_id, cf_value|
              field = custom_fields.detect { |cf| cf.id.to_s == cf_id}
              { cf_id => field ? field.format.convert_value(field, cf_value) : cf_value }
            end.reduce({}, &:merge)
            params[:issue][:custom_field_values] = converted_custom_field_values
          end
          true
        end

        def build_new_issue_from_params_with_empty_tracker
          if Setting.try(:plugin_redmine_improve_custom_fields)[:select_empty_tracker]
            if params[:id].blank?
              @issue = Issue.new
              if params[:copy_from]
                begin
                  @copy_from = Issue.visible.find(params[:copy_from])
                  @copy_attachments = params[:copy_attachments].present? || request.get?
                  @copy_subtasks = params[:copy_subtasks].present? || request.get?
                  @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks)
                rescue ActiveRecord::RecordNotFound
                  render_404
                  return
                end
              end
              @issue.project = @project
            else
              @issue = @project.issues.visible.find(params[:id])
            end

            @issue.project = @project
            @issue.author ||= User.current
            # Tracker must be set before custom field values

            @issue.tracker ||= @project.trackers.where(id: (params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id]).first

            @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?
            @issue.safe_attributes = params[:issue]

            @priorities = IssuePriority.active
            @allowed_statuses = @issue.new_statuses_allowed_to(User.current, @issue.new_record?)
            @available_watchers = @issue.watcher_users
            if @issue.project.users.count <= 20
              @available_watchers = (@available_watchers + @issue.project.users.sort).uniq
            end
          else
            build_new_issue_from_params_without_empty_tracker
          end
        end
      end
    end
  end
end
