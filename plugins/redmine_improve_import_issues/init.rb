Redmine::Plugin.register :redmine_improve_import_issues do
  name 'Redmine Improve Import Issues plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require 'services/import_xlsx_issues'

  ImportsController.send(:include, RedmineImproveImportIssues::Patches::ImportsControllerPatch) unless ImportsController.included_modules.include? RedmineImproveImportIssues::Patches::ImportsControllerPatch
  Import.send(:include, RedmineImproveImportIssues::Patches::ImportPatch) unless Import.included_modules.include? RedmineImproveImportIssues::Patches::ImportPatch
end
