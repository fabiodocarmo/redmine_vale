#encoding: utf-8
Redmine::Plugin.register :redmine_auto_assign do
  name 'Redmine Atribuicao Automatica plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine'
  version '1.6'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings default: {}, :partial => 'settings/redmine_auto_assign_settings'

  menu :admin_menu, :atribuicao_automaticas, { controller: 'atribuicao_automaticas', action: 'index' }
  IssuesController.send(:include, BeforeRender) unless IssuesController.included_modules.include? BeforeRender
  IssuesController.send(:include, AutoAssign::Patches::IssuesControllerPatch) unless IssuesController.included_modules.include? AutoAssign::Patches::IssuesControllerPatch
  Issue.send(:include, AutoAssign::Patches::IssuePatch) unless Issue.included_modules.include? AutoAssign::Patches::IssuePatch
end
