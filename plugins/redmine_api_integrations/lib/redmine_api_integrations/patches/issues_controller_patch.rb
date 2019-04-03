module RedmineApiIntegrations
  module Patches
    # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
    module IssuesControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :show_issue, only: [:show], if: :api_request?
          before_filter :show_issues, only: [:index], if: :api_request?
          before_filter :create_issue, only: [:create], if: :api_request?
          before_filter :update_issue, only: [:update], if: :api_request?
        end
      end

      module ClassMethods; end

      module InstanceMethods
        
        def show_issue
          @journals = @issue.journals.includes(:user, :details).
                    references(:user, :details).
                    reorder(:created_on, :id).to_a
          @journals.each_with_index {|j,i| j.indice = i+1}
          @journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
          Journal.preload_journals_details_custom_fields(@journals)
          @journals.select! {|journal| journal.notes? || journal.visible_details.any?}
          @journals.reverse! if User.current.wants_comments_in_reverse_order?

          @changesets = @issue.changesets.visible.preload(:repository, :user).to_a
          @changesets.reverse! if User.current.wants_comments_in_reverse_order?

          @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
          @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
          @priorities = IssuePriority.active
          @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
          @relation = IssueRelation.new

          respond_to do |format|
            format.api  { render :action => 'show' }
          end
        end

        def show_issues
          retrieve_query
          
          #Editing query to bring all status
          @query.filters = { 'status_id' => {:operator => "*", :values => [""]} }
          @query.build_from_params(params)
          
          sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
          sort_update(@query.sortable_columns)
          @query.sort_criteria = sort_criteria.to_a

          if @query.valid?
            @offset, @limit = api_offset_and_limit
            @query.column_names = %w(author)
            @issue_count = @query.issue_count
            @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                    :order => sort_clause,
                                    :offset => @offset,
                                    :limit => @limit)
            @issue_count_by_group = @query.issue_count_by_group
            
            respond_to do |format|
              format.api  { render :action => 'issues' } if params[:author_id].present?
              format.api  { render :action => 'author_error', :status => :unprocessable_entity }
            end
          else
            respond_to do |format|
              format.api { render_validation_errors(@query) }
            end
          end
        end

        def create_issue
          user = User.find(params[:user_id])

          flag = ApiIntegration.tracker_exists(params[:tracker_id])

          unless flag
            @error_message = t(:wrong_tracker)
            respond_to do |format|
              format.api  { render :action => 'tracker_error', :status => :unprocessable_entity }
            end
            return
          end

          new_issue_params = {
            subject:     params[:subject],
            description: params[:description],
            project_id:  ApiIntegration.find_project_id_by_tracker(params[:tracker_id]), #params[:project_id],
            tracker_id:  params[:tracker_id],
            status_id: IssueStatus.find(1),
            start_date: Time.zone.now
          }

          @issue = Issue.new(new_issue_params)

          custom_values = params[:custom_fields]

          custom_fields = custom_values.map { |cv| {id: cv[:id], value: cv[:value]} }

          custom_fields.each do |cf|
            begin
              custom_field = CustomField.find(cf[:id].to_i)
            rescue ActiveRecord::RecordNotFound => e
              custom_field = nil
            end

            # Check if the value of the request are present in the list of the configured fields, 
            # if they are not, the values will be inserted in the list
            if !custom_field.nil?
              if custom_field.field_format == "grid"
                JSON.parse(cf[:value].gsub("=>", ":")).values.map do |row|
                  row.each do |field|
                    if Setting.plugin_redmine_api_integrations[:custom_field_api_integration].include? field[0]
                      self.check_insert_custom_fields(field[0], field[1])
                    end
                  end
                end  
              else   
                if Setting.plugin_redmine_api_integrations[:custom_field_api_integration].include? cf[:id] 
                  self.check_insert_custom_fields(cf[:id], cf[:value])
                end
              end
            end
          end

          @issue.custom_fields = custom_fields

          @issue.author = user

          @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
          
          if @issue.save
            respond_to do |format|
              format.api  { render :action => 'create' }
            end
          else
            respond_to do |format|
              format.api  { self.render_validation_errors(@issue) }
            end
          end
        end


        def update_issue
          return unless update_issue_from_params
      
          saved = true
          
          issue = Issue.find(params[:id])
          user = User.find(params[:user_id])

          unless issue.editable?(user)
            respond_to do |format|
              format.api  { render :action => 'forbidden', :status => 403 }
            end
            return
          end

          User.current = user
          @changes = []

          if !params[:note].nil?
            issue.init_journal(user, params[:note])
            @changes << t(:note_added)
          else
            issue.init_journal(user, "")
          end

          #unless params[:subject].nil?  
          #  issue.subject = params[:subject] 
          #end

          #unless params[:description].nil?  
          #  issue.description = params[:description] 
          #end

          #unless params[:project_id].nil?  
          #  issue.project_id = params[:project_id] 
          #end

          #unless params[:tracker_id].nil?  
          #  issue.tracker_id = params[:tracker_id] 
          #end

          #unless params[:assigned_to_id].nil?  
          #  issue.assigned_to_id = params[:assigned_to_id] 
          #end

          possible_statuses = issue.new_statuses_allowed_to(user)

          unless params[:status_id].nil?
            begin
              status = IssueStatus.find(params[:status_id])
            rescue ActiveRecord::RecordNotFound => e
              status = nil
            end

            if !status.nil? and status.in? possible_statuses
              if status.id != issue.status.id
                @changes << t(:status_changed)
              end
              issue.status = status
            else
              respond_to do |format|
                format.api  { render :action => 'error', :status => :unprocessable_entity }
              end
              return
            end
          end
          
          issue.updated_on = Time.zone.now

          #custom_values = params[:custom_fields]

          #unless custom_values.nil?
          #  issue.custom_fields = custom_values.map { |cv| {id: cv[:id], value: cv[:value]} }
          #end

          issue.save_attachments(params[:attachments])

          issue.save

          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?
          
          respond_to do |format|
            format.api  { render :action => 'update', :location => issue_url(@issue) }
          end
        end


        def render_validation_errors(objects)
          messages = Array.wrap(objects).map {|object| object.errors.full_messages}.flatten
          messages.delete_if {|message| message.include? t(:not_in_list) }
          self.render_api_errors(messages)
        end

        def render_api_errors(*messages)
          @error_messages = messages.flatten
          render :template => 'common/errors.api', :status => :unprocessable_entity, :layout => nil
        end

        #Add JSON value to Custom Field possible values
        def check_insert_custom_fields(id, value)
          begin
            custom_field = CustomField.find(id)
          rescue ActiveRecord::RecordNotFound => e
            custom_field = nil
          end

          if !custom_field.nil?
            if !custom_field.possible_values.include? value
              custom_field.possible_values << value
              custom_field.save
            end
          end
        end
      end
    end
  end
end
