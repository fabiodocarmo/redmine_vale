Redmine::Plugin.register :redmine_auto_change_status do
  name 'Redmine Auto Change Status plugin'
  author 'Visagio'
  description 'Change status automatically when open or save issue'
  version '1.2'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :auto_change_statuses, { controller: 'auto_change_statuses', action: 'index' }, caption: :auto_change_statuses

  IssuesController.send(:include, BeforeRender) unless IssuesController.included_modules.include? BeforeRender
  IssuesController.send(:include, RedmineAutoChangeStatus::Patches::IssuesControllerPatch) unless IssuesController.included_modules.include? RedmineAutoChangeStatus::Patches::IssuesControllerPatch
  Issue.send(:include, RedmineAutoChangeStatus::Patches::IssuePatch) unless Issue.included_modules.include? RedmineAutoChangeStatus::Patches::IssuePatch
end
