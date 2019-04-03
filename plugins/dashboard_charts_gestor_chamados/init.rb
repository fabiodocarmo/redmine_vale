Redmine::Plugin.register :dashboard_charts_gestor_chamados do
  name 'Gestor Chamados plugin - Vale'
  author 'Visagio'
  description ''
  version '0.1.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'


  Issue.send(:include, DashboardChartsGestorChamados::Patches::IssuePatch) unless Issue.included_modules.include? DashboardChartsGestorChamados::Patches::IssuePatch
end
