Redmine::Plugin.register :redmine_dashboard do
  name 'Redmine Widget plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '1.3'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :project_menu, :redmine_widget_dashboard, { controller: 'dashboard_widgets'    , action: 'index' }, caption: :redmine_widget, param: :project_id
  menu :admin_menu  , :redmine_widget          , { controller: 'admin_redmine_widgets', action: 'index' }, caption: :redmine_widget

  Role.send(:include, RedmineDashboard::Patches::RolePatch) unless Role.included_modules.include?(RedmineDashboard::Patches::RolePatch)
  Issue.send(:include, RedmineDashboard::Patches::IssuePatch) unless Issue.included_modules.include?(RedmineDashboard::Patches::IssuePatch)


  settings default: {}, partial: 'settings/redmine_widgets_settings'
end

plugins = {}
configs = {}
Dir.entries(File.join(Rails.root, 'plugins')).select {|entry| File.directory? File.join(Rails.root, 'plugins', entry) and !(entry =='.' || entry == '..') }.each do |plugin|
  plugins[plugin] = []
  plugin_confs = {}

  begin
    config_path = File.join(Rails.root, 'plugins', plugin, 'config', 'widgets.yml')
    plugin_confs = YAML.load(File.read(config_path))
    configs.merge!(plugin_confs)
  rescue
  end

  plugin_confs.each do |k, _v|
    plugins[plugin] << k
  end
end

REDMINE_DASHBOARD_PLUGINS = plugins.reject { |k,v| v.blank? }.with_indifferent_access
REDMINE_DASHBOARD_PLUGINS_CONFIG = configs.with_indifferent_access

Redmine::AccessControl.map do |map|
  map.permission :produtividade,  :dashboard => :dashboard
  map.project_module :dashboard do
    map.permission :redmine_widget_dashboard, { dashboard_widgets: [:index], redmine_widgets: [:index] }

    begin
      RedmineWidget.all.each do |widget|
        map.permission widget.name_id.to_sym, :dashboard => :dashboard
      end
    rescue
    end
  end
end
