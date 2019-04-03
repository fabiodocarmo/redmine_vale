Redmine::Plugin.register :redmine_auto_generate_issue do
  name 'Redmine Auto Generate Issue plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine'
  version '1.4'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  Issue.send(:include, RedmineAutoGenerateIssue::Patches::IssuePatch) unless Issue.included_modules.include? RedmineAutoGenerateIssue::Patches::IssuePatch

  menu :admin_menu, :auto_issues, { controller: 'auto_issues', action: 'index' }

end
