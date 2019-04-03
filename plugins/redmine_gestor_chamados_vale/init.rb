
Redmine::Plugin.register :redmine_gestor_chamados_vale do
  name 'Gestor Chamados plugin - Vale'
  author 'Visagio'
  description ''
  version '1.0.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require_dependency 'issue'
  require_dependency 'user'

  require 'gestor_chamados_vale/hooks/gestor_chamados_vale_hook_listener'

  Issue.send(:include, GestorChamadosVale::IssuePatch) unless Issue.included_modules.include?(GestorChamadosVale::IssuePatch)
  User.send(:include, GestorChamadosVale::UserPatch) unless User.included_modules.include?(GestorChamadosVale::UserPatch)
end
