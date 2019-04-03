class DashboardWidgetsController < ApplicationController
  unloadable
  before_filter :find_project, :authorize, only: :index

  def index
    @dashboards = DashboardWidget.all
  end

  protected
  def find_project
    @project = Project.find(params[:project_id])
  end
end
