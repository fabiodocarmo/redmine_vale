module GestorChamadas
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module IssuesControllerPatch
    def self.included(base) # :nodoc
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in developmen
        before_render :verify_answer
        before_render :set_assign
        before_render :set_allowed_statuses

        alias_method_chain :find_issue, :disabled_archived_edit
        alias_method_chain :build_new_issue_from_params, :one_child
      end
    end

    module ClassMethods; end

    module InstanceMethods
      def build_new_issue_from_params_with_one_child
        @issue = Issue.new
        if params[:copy_from]
          begin
            @issue.init_journal(User.current)
            @copy_from = Issue.visible.find(params[:copy_from])
            unless User.current.allowed_to?(:copy_issues, @copy_from.project)
              raise ::Unauthorized
            end
            if (Issue.find(@copy_from.id).tracker.id.to_s.in? Setting.plugin_redmine_gestor_chamadas[:disable_copy_from_closed_issues]) && Issue.find(@copy_from.id).status.is_closed
              render_error :message => l(:unable_copy_closed), :status => 403
            end
            if Issue.find(@copy_from.id).only_one_child_issue? == false
              render_error :message => l(:one_child_issue_error), :status => 403
            end
            @link_copy = link_copy?(params[:link_copy]) || request.get?
            @copy_attachments = params[:copy_attachments].present? || request.get?
            @copy_subtasks = params[:copy_subtasks].present? || request.get?
            @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks, :link => @link_copy)
            @issue.parent_issue_id = @copy_from.parent_id
          rescue ActiveRecord::RecordNotFound
            render_404
            return
          end
        end
        @issue.project = @project
        if request.get?
          if @issue.project.blank? || !@issue.project.in?(@issue.allowed_target_projects)
            @issue.project = @issue.allowed_target_projects.sorted.first
          end
        end
        @issue.author ||= User.current
        @issue.start_date ||= User.current.today if Setting.default_issue_start_date_to_creation_date?

        attrs = (params[:issue] || {}).deep_dup
        if action_name == 'new' && params[:was_default_status] == attrs[:status_id]
          attrs.delete(:status_id)
        end
        if action_name == 'new' && params[:form_update_triggered_by] == 'issue_project_id'
          # Discard submitted version when changing the project on the issue form
          # so we can use the default version for the new project
          attrs.delete(:fixed_version_id)
        end
        @issue.safe_attributes = attrs

        if @issue.project

          # Block copy if new issue tracker is not the same as the original
          if @copy_from
            if (@copy_from.tracker_id.to_s.in? Setting.plugin_redmine_gestor_chamadas[:redirect_copy_error]) && (@issue.tracker_id != @copy_from.tracker_id)
              all_projects = Project.all
              encaminhar = Array.new
              all_projects.each do |p|
                if p.trackers.ids.include? @copy_from.tracker_id
                  encaminhar << p.name
                end
              end
              remover_projeto = Array.new
              remover_projeto << Project.find(@copy_from.project_id).name

              # remover após migração dos chamados
              remover_projeto << ["Análise de Físico Fiscal", "Análise de Área Remota", "Análise de Fiscal Físico", "Análise de Insumos"]
              remover_projeto.flatten!
              ###

              encaminhar = encaminhar - remover_projeto
              render_error :message => l(:redirect_copy_error, tracker: @copy_from.tracker.name, projects: encaminhar.each {|e| "#{e}"}.join(', ')) , :status => 403
            end
          end
          @issue.tracker ||= @issue.allowed_target_trackers.first
          if @issue.tracker.nil?
            if @issue.project.trackers.any?
              # None of the project trackers is allowed to the user
              render_error :message => l(:error_no_tracker_allowed_for_new_issue_in_project), :status => 403
            else
              # Project has no trackers
              render_error l(:error_no_tracker_in_project)
            end
            return false
          end
          if @issue.status.nil?
            render_error l(:error_no_default_issue_status)
            return false
          end
        end

        @priorities = IssuePriority.active
        @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    end



      def verify_answer
        return unless action_name == 'show'
        return if User.current.admin

        return unless @issue && @issue.priority.id == Setting.plugin_redmine_gestor_chamadas[:answered_priority].to_i

        @issue.priority = IssuePriority.find(Setting.plugin_redmine_gestor_chamadas[:normal_priority])
        @issue.save(validate: false)
      end

      def set_assign
        return unless action_name == 'show'
        return if User.current.admin

        return unless @issue && (@issue.assigned_to.nil? || (@issue.assigned_to == User.current)) && @issue.assignable_users.include?(User.current) && @issue.author != User.current
        return unless @issue.status_id == Setting.plugin_redmine_gestor_chamadas[:new_status].to_i

        @issue.status      = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:doing_status]) unless Setting.plugin_redmine_gestor_chamadas[:doing_status].blank?
        @issue.assigned_to = User.current

        @issue.save(validate: false)

        @new_journal = Journal.new(:journalized => @issue, :user => User.current)
        @new_journal.details << JournalDetail.new(:property => 'attr', :prop_key => 'status_id',:old_value => Setting.plugin_redmine_gestor_chamadas[:new_status], :value => @issue.status_id)
        @issue.journals << @new_journal
        @issue.save(validate: false)

      end

      def set_allowed_statuses
        return unless action_name == 'show'
        return if User.current.admin
        return unless @issue

        @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
      end

      def find_issue_with_disabled_archived_edit
        find_issue_without_disabled_archived_edit
        if request.params["action"].eql?("edit") && !@issue.attributes_editable?
          raise Unauthorized
        end
      end
    end
  end
end
