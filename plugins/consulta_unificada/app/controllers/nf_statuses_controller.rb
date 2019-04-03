class NfStatusesController < ApplicationController
  unloadable

  before_filter :find_dashboard_widget, only: [:show, :edit, :update, :destroy]
  before_filter :build_dashboard_widget, only: [:new, :create]

  def index
    @nf_statuses = NfStatus.all
  end

  def show; end

  def new; end

  def create
    if @nf_status.save
      redirect_to nf_statuses_path(@dashboard), notice: l(:status_creation_sucess_message)
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    if @nf_status.update_attributes(params[:nf_status])
      redirect_to nf_statuses_path(@dashboard), notice: l(:status_update_sucess_message)
    else
      render action: 'edit'
    end
  end

  def destroy
    @nf_status.destroy
    redirect_to nf_statuses_path
  end

  protected

  def find_dashboard_widget
    @nf_status = NfStatus.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def build_dashboard_widget
    @nf_status = NfStatus.new(params[:nf_status])
  end

end
