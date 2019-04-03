module RedmineApiIntegrations
  module Patches
    module IssueRelationsControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :copy_issue, only: [:create], if: :api_request?
          before_filter :require_admin, :except => :create
          before_filter :require_admin_or_api_request, :only => :create
          accept_api_auth :create
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def copy_issue
          user = User.find(params[:user_id])
          User.current = user
          @issue = Issue.find(params[:issue_id])

          check_issue_relations = self.check_child_issues_open(@issue)
          
          unless !check_issue_relations
            respond_to do |format|
              format.api  { render :action => 'child_exists', :status => :unprocessable_entity }
            end
            return
          end

          @child_issue = Issue.new
          @child_issue = self.copy_from(@issue, @child_issue)
          @child_issue.parent_id = @issue
          @child_issue.author = user
          @child_issue.project = Project.find(params[:project_id])
          @child_issue.save(validate:false)

          if @issue.tracker.id.to_s.in? Setting.plugin_redmine_gestor_chamadas[:change_status_copy_trackers]
            @issue.init_journal(user)
            @issue.status_id = Setting.plugin_redmine_gestor_chamadas[:copied_status_to]
            @issue.save(validate:false)
          end

          @relation = IssueRelation.new
          @relation.issue_from = @issue
          @relation.issue_to = @child_issue
          @relation.relation_type = 'copied_to'
          @relation.init_journals(User.current)
          saved = @relation.save

          if saved
            respond_to do |format|
              format.api  { render :action => 'create' }
            end
          else
            respond_to do |format|
              format.api  { self.render_validation_errors(@child_issue) }
            end
          end
        end

        def copy_from(parent_issue, child_issue)
          child_issue.attributes = parent_issue.attributes.dup.except("id", "root_id", "parent_id", "lft", "rgt", "created_on", "updated_on")
          child_issue.custom_field_values = parent_issue.custom_field_values.inject({}) {|h,v| h[v.custom_field_id] = v.value; h}
          child_issue.status = parent_issue.status
          child_issue.author = User.current
          child_issue.attachments = parent_issue.attachments.map do |attachement|
            attachement.copy(:container => self)
          end
          @copied_from = parent_issue
          return child_issue
        end

        def check_child_issues_open(issue)
          issue.relations.map do |row|
            child_issue = Issue.find(row[:issue_to_id])
            if !child_issue.status.is_closed?
              return true
            end
          end 
          return false
        end
      end
    end
  end
end
