class OfficeHoursController < CrujCrujCrujController
  unloadable

  def index_attributes
    [
      :name
    ]
  end

  def model_name
    'VsgSla::OfficeHour'
  end

  def show
    @office_hour = VsgSla::OfficeHour.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new
    @office_hour = VsgSla::OfficeHour.new
  end

  def create
    @office_hour = VsgSla::OfficeHour.new(params[:vsg_sla_office_hour])
    respond_to do |format|
      if @office_hour.save
        format.html do
          redirect_to(vsg_sla_office_hours_path, notice: t('office_hour.create_success'))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'new' }
        format.xml  do
          render xml: @office_hour.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @office_hour = VsgSla::OfficeHour.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update
    @office_hour = VsgSla::OfficeHour.find(params[:id])
    respond_to do |format|
      if @office_hour.update_attributes(params[:vsg_sla_office_hour])
        format.html do
          redirect_to(vsg_sla_office_hours_path, notice: t('office_hour.update_success'))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  do
          render xml: @office_hour.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def destroy
    @office_hour = VsgSla::OfficeHour.find(params[:id])
    @office_hour.destroy
    respond_to do |format|
      format.html { redirect_to(vsg_sla_office_hours_path) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
