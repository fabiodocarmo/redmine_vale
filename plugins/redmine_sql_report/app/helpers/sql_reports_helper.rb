module SqlReportsHelper

  def filter_list(filter)
    filter = filter.gsub("_id", "")
    filter_by_project = project_filter(filter)
    projects = []
    #Filter projects
    if filter_by_project # Select current project
      projects << @project
      filter = filter_by_project
    else # Select allowed_to projects
      projects = Project.visible(User.current)
    end

    case filter
    when Project.table_name
      return projects # Show only allowed_to projects
    when Tracker.table_name
      return trackers_by_project(projects) # Show trackers of selected projects
    when IssueStatus.table_name
      return statuses_by_project(projects) # Show statuses of selected projects throw trackers
    when CustomField.table_name
      return custom_fields_by_project(projects) # Show cfs of selected projects throw trackers
    else
      return filter.classify.constantize.all
    end

  end

  private

    def trackers_by_project(projects)
      projects.map(&:trackers).flatten.uniq
    end

    def statuses_by_project(projects)
      trackers_by_project(projects).map(&:issue_statuses).flatten.uniq
    end

    def custom_fields_by_project(projects)
      trackers_by_project(projects).map(&:custom_fields).flatten.uniq
    end

    # Recognizes filter by project. Ex: project_trackers_id
    def project_filter(filter)
      filter_without_project = filter.gsub("project_", "")
      return nil if filter == filter_without_project
      filter_without_project
    end

    def string_method_filter(filter)
      filter_by_project = project_filter(filter)
      if filter_by_project
        filter = filter_by_project
      end
      filter = filter.gsub("_id", "")
      klass = filter.classify.constantize.all

      if klass.first.methods.include?(:name) == true
        return "name"
      else
        return "to_s"
      end
      
    end

end
