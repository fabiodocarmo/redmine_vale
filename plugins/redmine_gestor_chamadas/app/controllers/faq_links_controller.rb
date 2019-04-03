class FaqLinksController < ApplicationController
  unloadable
  before_filter :require_admin

  def index
    @faq_links = FaqLink.all
  end

  def show
    @faq_link = FaqLink.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new
    @faq_link = FaqLink.new
  end

  def edit
    @faq_link = FaqLink.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update
    @faq_link = FaqLink.find(params[:id])
    respond_to do |format|
      if @faq_link.update_attributes(safe_parameters)
        format.html do
          redirect_to(@faq_link, notice: l(:link_sucessfully_updated_message))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  do
          render xml: @faq_link.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def create
    @faq_link = FaqLink.new(safe_parameters)
    respond_to do |format|
      if @faq_link.save
        format.html do
          redirect_to(@faq_link, notice: l(:link_sucessfully_created_message))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'new' }
        format.xml  do
          render xml: @faq_link.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @faq_link = FaqLink.find(params[:id])
    @faq_link.destroy
    respond_to do |format|
      format.html { redirect_to(faq_links_url) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private
  def safe_parameters
    params.require(:faq_link).permit(:faq_link, :tracker_id)
  end

end
