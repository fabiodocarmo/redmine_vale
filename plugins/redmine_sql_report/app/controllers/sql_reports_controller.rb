#encoding: utf-8
class SqlReportsController < ApplicationController
  unloadable
  before_filter :require_admin

  def index
    @sql_reports = SqlReport.all
  end

  def show
    @sql_report = SqlReport.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new
    @sql_report = SqlReport.new
  end

  def edit
    @sql_report = SqlReport.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update
    @sql_report = SqlReport.find(params[:id])
    respond_to do |format|
      if @sql_report.update_attributes(params[:sql_report])
        format.html do
          redirect_to(@sql_report, notice: l(:report_edit_sucess_message))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  do
          render xml: @sql_report.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def create
    @sql_report = SqlReport.new(params[:sql_report])
    respond_to do |format|
      if @sql_report.save
        format.html do
          redirect_to(@sql_report, notice: l(:report_create_sucess_message))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'new' }
        format.xml  do
          render xml: @sql_report.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @faq_link = SqlReport.find(params[:id])
    @faq_link.destroy
    respond_to do |format|
      format.html { redirect_to(sql_reports_url) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
