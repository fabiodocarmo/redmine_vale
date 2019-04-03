#encoding: utf-8

Redmine::Plugin.register :redmine_dashboard_defaultcharts do
  name 'Dashboard charts plugin'
  author 'Visagio'
  description 'This is a plugin for Redmine'
  version '1.0.3'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings default: {}, partial: 'settings/dashboard_charts_settings'
end
