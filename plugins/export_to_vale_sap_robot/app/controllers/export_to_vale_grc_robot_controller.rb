class ExportToValeGrcRobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def import_grc_report
    if params[:file].blank?
      redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), {flash: {error: l(:no_file_to_import_error_message)}}
      return
    end

    @attachment = Attachment.new(:file => params[:file].tempfile)
    @attachment.author = User.current
    @attachment.filename = Redmine::Utils.random_hex(16)
    @attachment.content_type = params[:file].content_type
    @attachment.save!

    #Back to later
    filename = ExportToValeSapRobot::Services::ImportNfs.import_grc_report(@attachment.diskfile, User.current.id, params[:project_id])
    # ImportGrcJob.perform_now(@attachment.diskfile, User.current.id, params[:project_id])
    if filename
      send_file(filename, filename: 'Export_robo_grc.xlsx', type: "application/vnd.ms-excel")
      # redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), notice: l(:grc_import_success)
    else
      redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), {flash: {error: l(:error_export_grc), notice: l(:grc_import_success)}} and return
    end
  end

  def update_grc_robot_ok
    log_type = 'ok'
    issue_id_col = 1
    journal_msg_col = nil
    custom_field_cols = []
    custom_field_cols << {id: Setting.plugin_export_to_vale_sap_robot['nfse_miro'], col: -2}
    current_status_id = Setting.plugin_export_to_vale_sap_robot['grc_robot_status_id']
    new_status_id = Setting.plugin_export_to_vale_sap_robot['grc_success_robot_status_id']
    flash_hash = ExportToValeSapRobot::Services::ImportNfs.
      update_issues_by_log(params, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), flash_hash
  end

  def update_grc_robot_error
    log_type = 'error'
    issue_id_col = 1
    journal_msg_col = -1
    custom_field_cols = []
    current_status_id = Setting.plugin_export_to_vale_sap_robot['grc_robot_status_id']
    new_status_id = Setting.plugin_export_to_vale_sap_robot['grc_error_robot_status_id']
    flash_hash = ExportToValeSapRobot::Services::ImportNfs.
      update_issues_by_log(params, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), flash_hash
  end

  def update_send_to_nfse_robot
    if params[:file].blank?
      redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), {flash: {error: l(:no_file_to_import_error_message)}}
      return
    end

    @attachment = Attachment.new(:file => params[:file].tempfile)
    @attachment.author = User.current
    @attachment.filename = Redmine::Utils.random_hex(16)
    @attachment.content_type = params[:file].content_type
    @attachment.save!

    ImportNoNfseJob.perform_later(@attachment.diskfile, User.current.id, params[:project_id])

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), notice: l(:grc_import_success) and return
  end

  protected
  def find_project
    @project = Project.find(params[:project_id])
  end
end
