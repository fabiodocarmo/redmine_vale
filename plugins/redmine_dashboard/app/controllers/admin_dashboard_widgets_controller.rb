class AdminDashboardWidgetsController < CrujCrujCrujController
  unloadable

  def index
    @dashboards = DashboardWidget.all
  end

  def index_attributes
    [
      :name,
      :priority
    ]
  end

  def model_name
    'DashboardWidget'
  end

  def show_graph_values
    @hash = {:show_graph_values => Setting.plugin_redmine_dashboard[:show_legend] }
    render :json => @hash
  end

end
