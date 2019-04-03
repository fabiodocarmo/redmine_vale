class DashboardProjects
  unloadable

  def self.valid_projects(widget_id,project_id)
    widget = RedmineWidget.where(name_id:widget_id).first
    parent = Project.find(project_id)

    Project.where('lft >= ? and rgt <= ?', parent.lft, parent.rgt)
  end

end
