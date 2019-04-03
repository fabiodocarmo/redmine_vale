Redmine::Plugin.register :redmine_escalation_vale do
  name 'Redmine Escalation Vale plugin'
  author 'Gabriel Rodrigues'
  description "This plugin enables the notification of responsability functionality, making possibly to notify assignee's superiors about issues with SLA expired"
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  Redmine::MenuManager.map :top_menu do |menu|
      menu.push :escalation, { :controller => 'escalation', :action => 'index' }, :if => Proc.new { User.current.admin? }, :caption => :escalator_menu_name,:last => true
    end
end
