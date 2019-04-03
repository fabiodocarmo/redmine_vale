module RedmineBulkUpdate
  module Patches
    module IssuesControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          alias_method_chain :bulk_update, :mass_update
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def bulk_update_with_mass_update
          @issues.sort!
          @copy = params[:copy].present?

          attributes = parse_params_for_bulk_update(params[:issue])
          copy_subtasks = (params[:copy_subtasks] == '1')
          copy_attachments = (params[:copy_attachments] == '1')

          if @copy
            unless User.current.allowed_to?(:copy_issues, @projects)
              raise ::Unauthorized
            end
            target_projects = @projects
            if attributes['project_id'].present?
              target_projects = Project.where(:id => attributes['project_id']).to_a
            end
            unless User.current.allowed_to?(:add_issues, target_projects)
              raise ::Unauthorized
            end
          else
            unless @issues.all?(&:attributes_editable?)
              raise ::Unauthorized
            end
          end

          unsaved_issues = []
          saved_issues = []

          if @copy && copy_subtasks
            # Descendant issues will be copied with the parent task
            # Don't copy them twice
            @issues.reject! {|issue| @issues.detect {|other| issue.is_descendant_of?(other)}}
          end

          mass_assignment = (attributes.keys.count == 1 && attributes.keys.first == 'assigned_to_id')
          if mass_assignment
            new_assignee = attributes.first.last
            Issue.transaction do
              Issue.where(id: @issues).update_all(assigned_to_id: new_assignee, updated_on: Time.zone.now)
              @issues.each { |i|
                journal = Journal.new
                journal.journalized = i
                journal.send(:add_attribute_detail, 'assigned_to_id', i.assigned_to_id, new_assignee)
                journal.notify = false
                journal.user_id = User.current.id
                journal.save!
              }
            end
          else
            @issues.each do |orig_issue|
              orig_issue.reload
              if @copy
                issue = orig_issue.copy({},
                                        :attachments => copy_attachments,
                                        :subtasks => copy_subtasks,
                                        :link => link_copy?(params[:link_copy])
                )
              else
                issue = orig_issue
              end
              journal = issue.init_journal(User.current, params[:notes])
              issue.safe_attributes = attributes
              call_hook(:controller_issues_bulk_edit_before_save, { :params => params, :issue => issue })
              if issue.save
                saved_issues << issue
              else
                unsaved_issues << orig_issue
              end
            end
          end

          if unsaved_issues.empty?
            flash[:notice] = l(:notice_successful_update) unless saved_issues.empty?
            if params[:follow]
              if @issues.size == 1 && saved_issues.size == 1
                redirect_to issue_path(saved_issues.first)
              elsif saved_issues.map(&:project).uniq.size == 1
                redirect_to project_issues_path(saved_issues.map(&:project).first)
              end
            else
              redirect_back_or_default _project_issues_path(@project)
            end
          else
            @saved_issues = @issues
            @unsaved_issues = unsaved_issues
            @issues = Issue.visible.where(:id => @unsaved_issues.map(&:id)).to_a
            bulk_edit
            render :action => 'bulk_edit'
          end
        end
      end
    end
  end
end
