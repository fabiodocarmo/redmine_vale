#encoding: utf-8
Redmine::Plugin.register :redmine_approvals do
  name 'Redmine Approvals plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '2.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :approvals, { controller: 'approvals', action: 'index' }
  settings default: {}, partial: 'settings/approvals_settings'

  Issue.send(:include, RedmineApprovals::Patches::IssuePatch) unless Issue.included_modules.include? RedmineApprovals::Patches::IssuePatch
end
