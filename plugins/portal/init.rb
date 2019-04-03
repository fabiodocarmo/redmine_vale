Redmine::Plugin.register :portal do
  name 'Portal plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require_dependency 'portal/hooks/left_block_hook'
  require_dependency 'portal/hooks/right_block_hook'
  require_dependency 'portal/hooks/project_hook'
  require_dependency 'portal/hooks/issues_hook'



  settings default: {default_project_page: :default}, partial: 'settings/portal'

  Project.send(:include, Portal::Patches::ProjectPatch) unless Project.included_modules.include? Portal::Patches::ProjectPatch

  WelcomeController.send(:include, Portal::Patches::WelcomeControllerPatch) unless WelcomeController.included_modules.include? Portal::Patches::WelcomeControllerPatch
  ApplicationHelper.send(:include, Portal::Patches::ApplicationHelperPatch) unless ApplicationHelper.included_modules.include? Portal::Patches::ApplicationHelperPatch
  ProjectsHelper.send(:include, Portal::Patches::ProjectsHelperPatch) unless ProjectsHelper.included_modules.include? Portal::Patches::ProjectsHelperPatch
end
