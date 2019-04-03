class DependentFieldsController < CrujCrujCrujController
  unloadable

  before_filter :find_dependent_field, only: [:show, :edit, :update, :destroy]
  before_filter :build_dependent_field, only: [:new, :create]

  def index_attributes
    [
      :avaliable,
      :project,
      :tracker,
      [:dependent_type, DependentField::DEPENDENT_TYPE],
      :main_field,
      :main_field_value,
      :secondary_field,
      :not_nullable,
      :secondary_field_value
    ]
  end

  def find_suggestion
    @dependent_fields = DependentField.where(avaliable: true)
                        .where("(project_id = ? or project_id is null) and (tracker_id = ? or tracker_id is null) and dependent_type = 'sugestion'
                          and main_field_id = ? and main_field_value = ?",
                           params[:project_id], params[:tracker_id], params[:id], params[:value])
                        .pluck(:secondary_field_id, :secondary_field_value)

    render json: @dependent_fields.to_json
  end

  def show; end

  def new; end

  def create
    if @dependent_field.save
      redirect_to dependent_field_path(@dependent_field), notice: l(:dependency_create_sucess_message)
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @dependent_field.update_attributes(params[:dependent_field])
      redirect_to dependent_field_path(@dependent_field), notice: l(:dependency_edit_sucess_message)
    else
      render action: 'edit'
    end
  end

  def destroy
    @dependent_field.destroy
    redirect_to dependent_fields_path
  end

  def import
    if params[:file].blank?
      redirect_to dependent_fields_url, {flash: {error: l(:no_file_to_import_error_message)}}
      return
    end

    errors = DependentFieldsManagement::Services::ImportRules.import(params[:file])
    if errors.blank?
      redirect_to dependent_fields_url, notice: l(:import_success_message)
      return
    end

    redirect_to dependent_fields_url, flash: { import_errors: errors.join('<br />') }
  end

  def export_template
    filename = DependentFieldsManagement::Services::ImportRules.export_template
    send_file(filename, filename: "dependent_fields_import_template.xlsx", type: "application/vnd.ms-excel")
  end

  protected

  def find_dependent_field
    @dependent_field = DependentField.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def build_dependent_field
    @dependent_field = DependentField.new(params[:dependent_field])
  end

  def filter_for_main_field
    "main_field_name_cont"
  end

  def filter_for_secondary_field
    "secondary_field_name_cont"
  end

end
