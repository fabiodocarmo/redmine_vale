Redmine::Plugin.register :redmine_alerts do
  name 'Redmine Alerts'
  author 'Visagio'
  description 'Plugin de customização de alertas para o Redmine'
  version '1.0.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require 'redmine_alerts/hooks/redmine_alerts_hook_listener'
  settings default: {}, partial: 'settings/redmine_alerts_settings'
end
