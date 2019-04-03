#encoding: utf-8


SQL_REPORT_ROOT_DIRECTORY = 'tmp/sql_report'

FileUtils.mkdir_p(SQL_REPORT_ROOT_DIRECTORY) unless File.directory?(SQL_REPORT_ROOT_DIRECTORY)

Redmine::Plugin.register :redmine_sql_report do
  name 'Redmine Sql Report plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '2.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :project_menu, :sql_reports_project, { controller: :project_sql_reports, action: 'index' }, caption: :sql_reports, param: :project_id
  menu :admin_menu, :sql_reports, { controller: 'sql_reports', action: 'index' }
end

Rails.configuration.after_initialize do
  begin
    Redmine::AccessControl.map do |map|
      map.project_module :sql_reports do
        map.permission :sql_reports_project, { :project_sql_reports => [:index, :show, :generate] }

        SqlReport.all.each do |widget|
          map.permission I18n.transliterate(widget.name).titleize.split.join.underscore.to_sym, { :project_sql_reports => [:index, :show, :generate] }
        end
      end
    end
  rescue
  end
end
