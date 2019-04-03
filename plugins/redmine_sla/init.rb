Redmine::Plugin.register :redmine_sla do
  name 'Redmine Sla plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine'
  version '2.4'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require_dependency 'redmine_sla/hooks/add_sla_icon_hook'

  menu :admin_menu  , :slas_settings, { controller: 'slas_settings', action: :index } , :caption => :slas_settings
  menu :project_menu, :sla_reports, { controller: 'sla_reports', action: :index }, :caption => :sla_reports, param: :project_id

  Issue.send(:include, RedmineSla::Patches::IssuePatch) unless Issue.included_modules.include? RedmineSla::Patches::IssuePatch
  IssuePriority.send(:include, RedmineSla::Patches::IssuePriorityPatch) unless IssuePriority.included_modules.include? RedmineSla::Patches::IssuePriorityPatch

  Project.send(:include, RedmineSla::Modules::SlaModule) unless Project.included_modules.include? RedmineSla::Modules::SlaModule
  Tracker.send(:include, RedmineSla::Modules::SlaModule) unless Tracker.included_modules.include? RedmineSla::Modules::SlaModule

  IssueStatus.send(:include, RedmineSla::Modules::SlaModule) unless IssueStatus.included_modules.include? RedmineSla::Modules::SlaModule

  project_module :sla_report do
    permission :sla_report, sla_reports: :index
  end
end
