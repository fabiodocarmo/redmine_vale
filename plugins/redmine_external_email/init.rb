Redmine::Plugin.register :redmine_external_email do
  name 'Redmine External Email plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :redmine_external_emails, { controller: 'redmine_external_emails', action: 'index' }
  Issue.send(:include, RedmineExternal::Patches::IssuePatch) unless Issue.included_modules.include? RedmineExternal::Patches::IssuePatch
end
