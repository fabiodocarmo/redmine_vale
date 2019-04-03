class ApiIntegrationsController < CrujCrujCrujController
  unloadable
  before_filter :require_admin
  

  def index_attributes
    [
      :project,
      :tracker
    ]
  end

  def filter_for_success_status
    "success_status_name_cont"
  end

  def form
    @resource = model_class.where(params.permit(:id)).first_or_initialize
    @resource.attributes = params.require(snake_case_model_name.to_sym).permit!
  end

  def show
  end
end
