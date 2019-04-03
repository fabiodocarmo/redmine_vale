Redmine::Plugin.register :redmine_exec_job do
  name 'Redmine Exec Job plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :exec_jobs, { controller: 'exec_jobs', action: 'index' }

  Issue.send(:include, RedmineExecJob::Patches::IssuePatch) unless Issue.included_modules.include? RedmineExecJob::Patches::IssuePatch
end

ExampleExecJob.register
