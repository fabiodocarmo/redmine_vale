class SlasController < CrujCrujCrujController
  unloadable

  def index_attributes
    [
      :name,
      :sla
    ]
  end

  def model_name
    'VsgSla::Sla'
  end

  def show
    @sla = VsgSla::Sla.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new
    @sla = VsgSla::Sla.new
  end

  def form
    @sla = VsgSla::Sla.where(id: params[:id]).first_or_initialize
    @sla.attributes = params[:vsg_sla_sla]
  end

  def create
    @sla = VsgSla::Sla.new(params[:vsg_sla_sla])
    respond_to do |format|
      if @sla.save
        format.html do
          redirect_to(vsg_sla_slas_path, notice: t('sla.create_success'))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'new' }
        format.xml  do
          render xml: @sla.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @sla = VsgSla::Sla.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update
    @sla = VsgSla::Sla.find(params[:id])
    respond_to do |format|
      if @sla.update_attributes(params[:vsg_sla_sla])
        format.html do
          redirect_to(vsg_sla_slas_path, notice: t('sla.update_success'))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  do
          render xml: @sla.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def destroy
    @sla = VsgSla::Sla.find(params[:id])
    @sla.destroy
    respond_to do |format|
      format.html { redirect_to(vsg_sla_slas_path) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
