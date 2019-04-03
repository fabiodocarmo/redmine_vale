Redmine::Plugin.register :consulta_unificada do
  name 'Consulta Unificada plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require 'hooks/issues_consulta_hook_listener'

  menu :admin_menu, :nf_statuses, { controller: 'nf_statuses', action: 'index' }
  settings default: {}, partial: 'settings/consulta_unificada_settings'

  Issue.send(:include, Patches::ConsultaIssuePatch) unless Issue.included_modules.include?(Patches::ConsultaIssuePatch)
end
