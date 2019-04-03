# encoding: UTF-8

# Copyright © Emilio González Montaña
# Licence: Attribution & no derivates
#   * Attribution to the plugin web page URL should be done if you want to use it.
#     https://redmine.ociotec.com/projects/localizable
#   * No derivates of this plugin (or partial) are allowed.
# Take a look to licence.txt file at plugin root folder for further details.

# This plugin should be reloaded in development mode.
if (Rails.env == "development")
  ActiveSupport::Dependencies.autoload_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end

require "redmine"
require "rubygems"

Role.send(:include, Localizable)
Tracker.send(:include, Localizable)
IssueStatus.send(:include, Localizable)
CustomField.send(:include, Localizable)
Enumeration.send(:include, Localizable)
Project.send(:include, Localizable)

Redmine::Plugin.register :localizable do
  name "Localizable plugin"
  url "https://redmine.ociotec.com/projects/localizable"
  author "Emilio González Montaña"
  author_url "http://ociotec.com"
  description "This is a plugin for Redmine that is used to show strings (issue types, issue statuses, enumerations, ...) in serveral languages"
  version "1.4"
  requires_redmine :version_or_higher => "2.1.0"

  settings(:default => {"default_language" => "en",
                        "locales_to_translate" => [],
                        "locales" => {"tracker" => {},
                                      "issue_status" => {}}},
           :partial => "settings/localizable")

  require_dependency 'localizable/patches/mailer_patch'

  Rails.configuration.to_prepare do
    Redmine::FieldFormat::List.send(:include, Localizable::Patches::ListPatch) unless Redmine::FieldFormat::List.included_modules.include?(Localizable::Patches::ListPatch)
    Issue.send(:include, Localizable::Patches::IssuePatch) unless Issue.included_modules.include?(Localizable::Patches::IssuePatch)
    CustomFieldsHelper.send(:include, Localizable::Patches::CustomFieldsHelperPatch) unless CustomFieldsHelper.included_modules.include?(Localizable::Patches::CustomFieldsHelperPatch)
    ApplicationHelper.send(:include, Localizable::Patches::ApplicationHelperPatch) unless ApplicationHelper.included_modules.include?(Localizable::Patches::ApplicationHelperPatch)
  end
end
