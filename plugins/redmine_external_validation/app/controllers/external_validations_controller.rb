class ExternalValidationsController < CrujCrujCrujController
  unloadable

  before_filter :require_admin

  def index_attributes
    [
      :project,
      :tracker,
      :status_from,
      :status_to,
      :success_status
    ]
  end

  def filter_for_success_status
    "success_status_name_cont"
  end

  def form
    @resource = model_class.where(params.permit(:id)).first_or_initialize
    @resource.attributes = params.require(snake_case_model_name.to_sym).permit!
  end
end
