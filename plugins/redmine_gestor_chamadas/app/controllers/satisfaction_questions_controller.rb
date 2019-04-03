class SatisfactionQuestionsController < CrujCrujCrujController
  unloadable

  before_filter :require_admin
  before_filter :find_satisfaction_question, only: [:show, :edit, :update, :destroy]
  before_filter :build_satisfaction_question, only: [:new, :create]

  def index_attributes
    [
      :question,
      :question_en,
      :question_es,
      :reopen_enabled
    ]
  end

  def show; end

  def new; end

  def edit; end

  def create
    if @satisfaction_question.save
      redirect_to satisfaction_questions_path(@satisfaction_question), notice: l(:satisfaction_create_sucess_message)
    else
      render action: 'new'
    end
  end

  def destroy
    @satisfaction_question.destroy
    redirect_to satisfaction_questions_path
  end

  def update
    if @satisfaction_question.update_attributes(params.require(:satisfaction_question).permit(:question,:question_en,:question_es,:reopen_enabled))
      redirect_to satisfaction_questions_path(@satisfaction_question), notice: l(:satisfaction_edit_sucess_message)
    else
      render action: 'edit'
    end
  end

  def import
    if params[:file].blank?
      redirect_to satisfaction_questions_url, {flash: {error: l(:no_file_to_import_error_message)}}
      return
    end

    errors = SatisfactionQuestionsManagement::Services::ImportRules.import(params[:file])
    if errors.blank?
      redirect_to satisfaction_questions_url, notice: l(:import_success_message)
      return
    end

    redirect_to satisfaction_questions_url, flash: { import_errors: errors.join('<br />') }
  end

  def export_template
    filename = SatisfactionQuestionsManagement::Services::ImportRules.export_template
    send_file(filename, filename: "Template_Pesquisa_Satisfacao.xlsx", type: "application/vnd.ms-excel")
  end


  protected

  def find_satisfaction_question
    @satisfaction_question = SatisfactionQuestion.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def build_satisfaction_question
    @satisfaction_question = SatisfactionQuestion.new(params[:satisfaction_question])
  end

  def filter_question
    "question_cont"
  end

end
