class DocumentTypeQueriesController < CrujCrujCrujController
  unloadable

  before_filter :require_admin

  def index_attributes
    [
      :project,
      :tracker,
      :status_from,
      :status_to
    ]
  end

  def form
    @resource = model_class.where(id: params.permit(:id)).first_or_initialize
    @resource.attributes = params.require(snake_case_model_name.to_sym).permit!
  end
end
