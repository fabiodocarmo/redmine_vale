Redmine::Plugin.register :redmine_api_integrations do
  name 'Plugin API Integration'
  author 'Erick Arruzzo'
  description 'Plugin API Restfull integration'
  version '1.0'
  url 'http://example.com/path/to/plugin'
  author_url 'https://projects.visagio.com/users/1309'

  menu :admin_menu, :api_integrations, { controller: 'api_integrations', action: 'index' }, caption: :redmine_api_integrations

  settings default: {}, partial: 'settings/api_integration'

  AttachmentsController.send(:include, RedmineApiIntegrations::Patches::AttachmentsControllerPatch) unless AttachmentsController.included_modules.include? RedmineApiIntegrations::Patches::AttachmentsControllerPatch
  CustomFieldsController.send(:include, RedmineApiIntegrations::Patches::CustomFieldsControllerPatch) unless CustomFieldsController.included_modules.include? RedmineApiIntegrations::Patches::CustomFieldsControllerPatch
  TrackersController.send(:include, RedmineApiIntegrations::Patches::TrackersControllerPatch) unless TrackersController.included_modules.include? RedmineApiIntegrations::Patches::TrackersControllerPatch
  WatchersController.send(:include, RedmineApiIntegrations::Patches::WatchersControllerPatch) unless WatchersController.included_modules.include? RedmineApiIntegrations::Patches::WatchersControllerPatch
  UsersController.send(:include, RedmineApiIntegrations::Patches::UsersControllerPatch) unless UsersController.included_modules.include? RedmineApiIntegrations::Patches::UsersControllerPatch
  IssuesController.send(:include, RedmineApiIntegrations::Patches::IssuesControllerPatch) unless IssuesController.included_modules.include? RedmineApiIntegrations::Patches::IssuesControllerPatch
  IssueStatusesController.send(:include, RedmineApiIntegrations::Patches::IssueStatusesControllerPatch) unless IssueStatusesController.included_modules.include? RedmineApiIntegrations::Patches::IssueStatusesControllerPatch
  IssueRelationsController.send(:include, RedmineApiIntegrations::Patches::IssueRelationsControllerPatch) unless IssueRelationsController.included_modules.include? RedmineApiIntegrations::Patches::IssueRelationsControllerPatch
  Journal.send(:include, RedmineApiIntegrations::Patches::JournalPatch) unless Journal.included_modules.include? RedmineApiIntegrations::Patches::JournalPatch
end
