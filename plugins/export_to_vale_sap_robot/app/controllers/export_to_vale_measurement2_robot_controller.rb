class ExportToValeMeasurement2RobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def create
    issues = ValeExportReplicaIssue
                  .where(project_id: @project.id)
                  .where(status_id: Setting.plugin_export_to_vale_sap_robot['measurement2_wating_status_id'])
                  .where(tracker_id: Setting.plugin_export_to_vale_sap_robot['measurement2_tracker_id'])
                  .joins(custom_values_joins_query('dados_pedido_frs', 'dados_pedido_frs_id'))
                  .joins(custom_values_joins_query('numero_requisicao', 'numero_requisicao_id'))
                  .joins(custom_values_joins_query('periodo_referencia', 'periodo_referencia_id'))
                  .joins(custom_values_joins_query('razao_social', 'razao_social_id'))
                  .joins(grid_joins_query('pedido', 'dados_pedido_frs.id', Setting.plugin_export_to_vale_sap_robot['measurement2_pedido_id']))
                  .joins(not_custom_values_joins_query('area', Setting.plugin_export_to_vale_sap_robot['measurement2_area_id'], 'Recursos Humanos - Benefícios'))
                  .select('\'\' || issues.id as "numero_chamado"')
                  .select('\'\' || numero_requisicao.value as "Número da Requisição"')
                  .select('\'\' || replace(to_char(to_date(substring(periodo_referencia.value from \'^[\/0-9]*\'), \'dd/MM/yy\'), \'dd/MM/yyyy\'), \'/\', \'.\') as "Período de"')
                  .select('\'\' || replace(to_char(to_date(substring(periodo_referencia.value from \'[\/0-9]*$\'), \'dd/MM/yy\'), \'dd/MM/yyyy\'), \'/\', \'.\') as "Período para"')
                  .select('\'\' || pedido.value as "Número do Pedido"')
                  .select('\'\' || CONCAT(CONCAT(CONCAT(RTRIM(substring(razao_social.value from \'^[a-zA-Z0-9,.;!@#$%*()+=-]*[ ]|^[a-zA-Z0-9,.;!@#$%*()+=-]*$\')), \'_\'), regexp_replace(regexp_replace(periodo_referencia.value, \'\/\d* a \', \'_\', \'g\'), \'\/\d*$\', \'\')), CONCAT(\'_\',issues.id)) as "Texto Breve"')
                  .order(:id)
    filename = ExportToValeSapRobot::Services::ImportNfs.export_measurement2_template(issues, ['numero_chamado'      ,
                                                                                               'Número da Requisição',
                                                                                               'Período de'          ,
                                                                                               'Período para'        ,
                                                                                               'Número do Pedido'    ,
                                                                                               'Texto Breve'])
    send_file(filename, filename: 'template_robo_frs.xlsx', type: "application/vnd.ms-excel")

    Issue.where(id: issues.map(&:numero_chamado)).each do |i|
      i.init_journal(User.find(12379))
      i.update_attribute(:status_id, Setting.plugin_export_to_vale_sap_robot['measurement2_robot_status_id'])
    end
  end

  def update
    if params[:file].blank?
      redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), {flash: {error: l(:no_file_to_import_error_message)}}
      return
    end

    begin
      ExportToValeSapRobot::Services::ImportNfs.open_xlsx_file(params[:file].tempfile.path)
    rescue
      redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), {flash: {error: l(:error_wrong_file_format)}}
      return
    end

    @attachment = Attachment.new(:file => params[:file].tempfile)
    @attachment.author = User.current
    @attachment.filename = Redmine::Utils.random_hex(16)
    @attachment.content_type = params[:file].content_type
    @attachment.save!

    ImportMeasurement2Job.perform_later(@attachment.diskfile, User.current.id)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), notice: l(:email_will_be_send_when_finish) and return
  end

  protected

  def custom_values_joins_query(table_alias, setting_id)
    custom_fields_ids = Array.wrap(Setting.plugin_export_to_vale_sap_robot["measurement2_#{setting_id}"]).join(', ')
    custom_fields_ids = 'null' if custom_fields_ids.blank?
    "left join custom_values #{table_alias} on #{table_alias}.customized_id = issues.id and #{table_alias}.customized_type = 'Issue' and #{table_alias}.custom_field_id in (#{custom_fields_ids})"
  end

  def not_custom_values_joins_query(table_alias, setting_id, not_value)
    "join custom_values #{table_alias} on #{table_alias}.customized_id = issues.id and #{table_alias}.customized_type = 'Issue' and #{table_alias}.custom_field_id = #{setting_id} and #{table_alias}.value != '#{not_value}'"
  end

  def users_joins_query(table_alias)
    "left join users #{table_alias} on issues.author_id = #{table_alias}.id"
  end

  def grid_joins_query(table_alias, setting_grid_id, setting_id, use_row = false, row_field = '')
    return "left join grid_values #{table_alias} on #{table_alias}.custom_value_id = #{setting_grid_id} and #{table_alias}.column = #{setting_id}" unless use_row
    "left join grid_values #{table_alias} on #{table_alias}.custom_value_id = #{setting_grid_id} and #{table_alias}.column = #{setting_id} and #{table_alias}.row = #{row_field}.row"

  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
