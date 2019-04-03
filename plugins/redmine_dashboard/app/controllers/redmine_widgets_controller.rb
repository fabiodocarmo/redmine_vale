class RedmineWidgetsController < ApplicationController
  unloadable
  before_filter :find_project, :authorize, only: :index

  def index
    @widgets = RedmineWidget.where(dashboard_widget_id: params[:dashboard_widget_id])
  end

  protected
  def find_project
    @project = Project.find(params[:project_id])
  end
end
