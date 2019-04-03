class ProjectSqlReportsController < ApplicationController
  unloadable
  before_filter :find_project, :authorize
  helper :sql_reports
  include SqlReportsHelper

  def index
    @sql_reports = SqlReport.all
  end

  def show
    @sql_report = SqlReport.find(params[:id])
  end

  def generate
    @sql_report = SqlReport.find(params[:id])

    if params[:filters]
      params[:filters][:nested_projects_ids] = valid_projects(params[:project_id]).map(&:id)
    end

    sql_report = SqlReport.find(params[:id])
    user = User.find(User.current)
    filters = params[:filters]

    execution = SqlReportExecution.create(sql_report: sql_report, requester: user, filters: filters)

    SqlReportJob.perform_later(execution.id)
    redirect_to url_for(action: :show, controller: params[:controller], id: params[:id], project_id: params[:project_id]), notice: l(:email_will_be_send_when_finish) and return
  end

  protected
  def find_project
    @project = Project.find(params[:project_id])
  end

  def trackers(project_id)
    projects = valid_projects(project_id)
    trackers = []

    projects.each do |project|
      trackers.concat(project.trackers)
    end

    trackers
  end

  def valid_projects(project_id)
    projects = Project.where('id = ? or projects.parent_id = ?',project_id, project_id)

    return projects unless projects.length > 1

    # Busca os netos
    (projects.map(&:id) - [project_id]).each do |child_project_id|
      projects = projects | valid_projects(child_project_id)
    end

    projects
  end
end
