Redmine::Plugin.register :redmine_bulk_update do
  name 'Plugin Redmine Bulk Update'
  author 'Erick Arruzzo'
  description 'Plugin de correção para edição massiva de chamados'
  version '1.0'
  url 'http://example.com/path/to/plugin'
  author_url 'https://projects.visagio.com/users/1309'

  IssuesController.send(:include, RedmineBulkUpdate::Patches::IssuesControllerPatch) unless IssuesController.included_modules.include? RedmineBulkUpdate::Patches::IssuesControllerPatch
end
