#encoding: utf-8
require_dependency 'gestor_chamadas/hooks/custom_field_hook'
require 'gestor_chamadas/hooks/issues_hook_listener'
require 'gestor_chamadas/hooks/issue_statuses_hook_listener'

Redmine::Plugin.register :redmine_gestor_chamadas do
  name 'Gestor de Chamados plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine'
  version '2.0.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require_dependency 'issues_controller'
#  require_dependency 'helpdesk_mailer'
  require_dependency 'issue'

  menu :admin_menu, :faq_links        , { controller: 'faq_links'        , action: 'index' }, caption: 'FAQ Links'
  menu :admin_menu, :satisfaction_questions        , { controller: 'satisfaction_questions'        , action: 'index' }, caption: 'Satisfaction Questions'

  IssuesController.send(:include, BeforeRender) unless IssuesController.included_modules.include? BeforeRender
  IssuesController.send(:include, GestorChamadas::IssuesControllerPatch) unless IssuesController.included_modules.include? GestorChamadas::IssuesControllerPatch

  #TODO: Isolate anonymous ticket creation to separate plugin
  #ApplicationController.send(:include, GestorChamadas::ApplicationControllerPatch) unless ApplicationController.included_modules.include? GestorChamadas::ApplicationControllerPatch
  AttachmentsController.send(:include, GestorChamadas::AttachmentsControllerPatch) unless AttachmentsController.included_modules.include? GestorChamadas::AttachmentsControllerPatch

#  HelpdeskMailer.send(:include, GestorChamadas::HelpdeskMailerPatch) unless HelpdeskMailer.included_modules.include? GestorChamadas::HelpdeskMailerPatch
  Issue.send(:include, GestorChamadas::IssuePatch) unless Issue.included_modules.include?(GestorChamadas::IssuePatch)
  ContextMenusController.send(:include, GestorChamadas::ContextMenusControllerPatch) unless ContextMenusController.included_modules.include?(GestorChamadas::ContextMenusControllerPatch)
  JournalsHelper.send(:include, GestorChamadas::JournalsHelperPatch) unless JournalsHelper.included_modules.include?(GestorChamadas::JournalsHelperPatch)
  IssuesHelper.send(:include, GestorChamadas::IssuesHelperPatch) unless IssuesHelper.included_modules.include?(GestorChamadas::IssuesHelperPatch)

  QueriesHelper.send(:include, GestorChamadas::QueriesHelperPatch) unless Issue.included_modules.include?(GestorChamadas::QueriesHelperPatch)
#  User.send(:include, GestorChamadas::UserPatch)

  settings default: {}, partial: 'settings/gestor_chamados_settings'

  project_module :issue_tracking do
    permission :visualizar_chamados_atribuicao, {}
  end
end
Rails.configuration.after_initialize do
  ValidateIssueIdFieldJob.register
end
