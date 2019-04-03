class AdminRedmineWidgetsController < CrujCrujCrujController
  unloadable
  before_filter :require_admin

  def index_attributes
    [
      :dashboard_widget,
      :priority,
      :name_id,
      :source_plugin,
    ]
  end

  def exclude_index_attributes
    []
  end

  def model_name
    'RedmineWidget'
  end

  def form
    build_resource
    if params[:id]
      @action = 'update'
    else
      @action = 'create'
    end
  end

  def update
    if @resource.update_attributes(widget_params)
      redirect_to(action: :index, notice: l("#{snake_case_model_name}_edit_success_message"))
    else
      render action: 'edit'
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  protected

  def build_resource
    @resource = params[:redmine_widget] ?  RedmineWidget.new(widget_params) : RedmineWidget.new
  end

  private

  def widget_params
    parameters = params.require(:redmine_widget).permit(:id, :source_plugin, :name_id, :dashboard_widget_id, :priority, :select_projects)

    parameters[:project_ids] = params[:redmine_widget][:project_ids]
    parameters[:custom_field_ids] = params[:redmine_widget][:custom_field_ids]

    parameters[:config] = params[:redmine_widget][:config]
    parameters
  end
end
