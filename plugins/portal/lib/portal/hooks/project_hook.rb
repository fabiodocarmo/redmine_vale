module Portal
  module Hooks
    class ProjectHook < Redmine::Hook::ViewListener
      render_on :view_projects_form, partial: 'hooks/project_form.html'
    end
  end
end
