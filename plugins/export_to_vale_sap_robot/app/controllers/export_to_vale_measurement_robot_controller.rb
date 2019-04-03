class ExportToValeMeasurementRobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def create
    issues = ValeExportReplicaIssue
                  .where(project_id: @project.id)
                  .where(status_id: Setting.plugin_export_to_vale_sap_robot['measurement_wating_status_id'])
                  .where(tracker_id: Setting.plugin_export_to_vale_sap_robot['measurement_tracker_id'])
                  .joins(custom_values_joins_query('razao_social', 'razao_social_id'))
                  .joins(custom_values_joins_query('numero_contrato', 'numero_contrato_id'))
                  .joins(contratos_joins_query('contratos', 'numero_contrato'))
                  .joins(custom_values_joins_query('periodo_referencia', 'periodo_referencia_id'))
                  .joins(custom_values_joins_query('local_prestacao_servico', 'local_prestacao_servico_id'))
                  .joins(users_joins_query('autor'))
                  .joins(custom_values_joins_query('nome_aprovador', 'nome_aprovador_id'))
                  .joins(custom_values_joins_query('numero_sap_aprovador', 'numero_sap_aprovador_id'))
                  .joins(custom_values_joins_query('descricao_servico', 'descricao_servico_id'))
                  .joins(custom_values_joins_query('moeda', 'moeda_id'))
                  .joins(custom_values_joins_query('valor', 'valor_id'))
                  .joins(custom_values_joins_query('linhas_contrato', 'linhas_contrato_id'))
                  .joins(grid_joins_query('linha_ct_sap', 'linhas_contrato.id', Setting.plugin_export_to_vale_sap_robot['measurement_linha_ct_sap_id']))
                  .joins(grid_joins_query('item_contrato_sap', 'linhas_contrato.id', Setting.plugin_export_to_vale_sap_robot['measurement_item_contrato_sap_id'], true, 'linha_ct_sap'))
                  .joins(grid_joins_query('centro_contratante', 'linhas_contrato.id', Setting.plugin_export_to_vale_sap_robot['measurement_centro_contratante_id'], true, 'linha_ct_sap'))
                  .joins(grid_joins_query('descricao_linha_medida', 'linhas_contrato.id', Setting.plugin_export_to_vale_sap_robot['measurement_descricao_linha_medida_id'], true, 'linha_ct_sap'))
                  .joins(grid_joins_query('quantidade_executada', 'linhas_contrato.id', Setting.plugin_export_to_vale_sap_robot['measurement_quantidade_executada_id'], true, 'linha_ct_sap'))
                  .joins(grid_joins_query('preco_unitario', 'linhas_contrato.id', Setting.plugin_export_to_vale_sap_robot['measurement_preco_unitario_id'], true, 'linha_ct_sap'))
                  .joins(grid_joins_query('conta_razao', 'linhas_contrato.id', Setting.plugin_export_to_vale_sap_robot['measurement_conta_razao_id'], true, 'linha_ct_sap'))
                  .joins(grid_joins_query('cdc_projeto_oe', 'linhas_contrato.id', Setting.plugin_export_to_vale_sap_robot['measurement_cdc_projeto_oe_id'], true, 'linha_ct_sap'))
                  .joins(not_custom_values_joins_query('area', Setting.plugin_export_to_vale_sap_robot['measurement_area_id'], 'Recursos Humanos - Benefícios'))
                  .select('\'\' || issues.id as "numero_chamado"')
                  .select('\'\' || razao_social.value as "Razão Social"')
                  .select('\'\' || case descricao_linha_medida.value ~* \'despesa|reembols\'
                    when \'true\' then
                      CONCAT(CONCAT(CONCAT(CONCAT(RTRIM(substring(razao_social.value from \'^[a-zA-Z0-9,.;!@#$%*()+=-]*[ ]|^[a-zA-Z0-9,.;!@#$%*()+=-]*$\')), \'_\'), regexp_replace(regexp_replace(periodo_referencia.value, \'\/\d* a \', \'_\', \'g\'), \'\/\d*$\', \'\')), CONCAT(\'_\',issues.id)), \'_RD\')
                    else
                      CONCAT(CONCAT(CONCAT(RTRIM(substring(razao_social.value from \'^[a-zA-Z0-9,.;!@#$%*()+=-]*[ ]|^[a-zA-Z0-9,.;!@#$%*()+=-]*$\')), \'_\'), regexp_replace(regexp_replace(periodo_referencia.value, \'\/\d* a \', \'_\', \'g\'), \'\/\d*$\', \'\')), CONCAT(\'_\',issues.id))
                    end
                    as "Texto Breve"')
                  .select('\'\' || numero_contrato.value as "Número do Contrato"')
                  .select('\'\' || contratos.org_compras as "Organização de Compras"')
                  .select('\'\' || periodo_referencia.value as "Período de Referência"')
                  .select('\'\' || local_prestacao_servico.value as "Local de Prestação do Serviço"')
                  .select('\'\' || CONCAT(CONCAT(autor.firstname, \' \'), autor.lastname) as "Autor"')
                  .select('\'\' || nome_aprovador.value as "Nome Completo do Aprovador"')
                  .select('\'\' || numero_sap_aprovador.value as "Número do SAP do Aprovador"')
                  .select('\'\' || descricao_servico.value as "Descrição do Serviço"')
                  .select('\'\' || moeda.value as "Moeda"')
                  .select('\'\' || valor.value as "Valor"')
                  .select('\'\' || linha_ct_sap.value as "Nº da Linha do CT no SAP"')
                  .select('\'\' || item_contrato_sap.value as "Item do Contrato no SAP"')
                  .select('\'\' || centro_contratante.value as "Centro - Contratante"')
                  .select('\'\' || descricao_linha_medida.value as "Descrição da Linha Medida"')
                  .select('\'\' || quantidade_executada.value as "Quantidade Executada"')
                  .select('\'\' || preco_unitario.value as "Preço Unitário QQP"')
                  .select('\'\' || conta_razao.value as "Conta Razão (Contábil)"')
                  .select('\'\' || cdc_projeto_oe.value as "CdC / Projeto / OE"')
                  .select('\'\' || cdc_projeto_oe.value as "Classificação Contábil"')
                  .order(:id, '"Item do Contrato no SAP"', '"Classificação Contábil"', '"Texto Breve"', '"CdC / Projeto / OE"')
    filename = ExportToValeSapRobot::Services::ImportNfs.export_measurement_template(issues, ['numero_chamado'               ,
                                                                                              'Razão Social'                 ,
                                                                                              'Texto Breve'                  ,
                                                                                              'Número do Contrato'           ,
                                                                                              'Organização de Compras',
                                                                                              'Período de Referência'        ,
                                                                                              'Local de Prestação do Serviço',
                                                                                              'Autor'                        ,
                                                                                              'Nome Completo do Aprovador'   ,
                                                                                              'Número do SAP do Aprovador'   ,
                                                                                              'Descrição do Serviço'         ,
                                                                                              'Moeda'                        ,
                                                                                              'Valor'                        ,
                                                                                              'Nº da Linha do CT no SAP'     ,
                                                                                              'Item do Contrato no SAP'      ,
                                                                                              'Centro - Contratante'         ,
                                                                                              'Descrição da Linha Medida'    ,
                                                                                              'Quantidade Executada'         ,
                                                                                              'Preço Unitário QQP'           ,
                                                                                              'Conta Razão (Contábil)'       ,
                                                                                              'CdC / Projeto / OE'           ,
                                                                                              'Classificação Contábil'])
    send_file(filename, filename: 'template_robo_requisicao.xlsx', type: "application/vnd.ms-excel")

    Issue.where(id: issues.map(&:numero_chamado)).each do |i|
      i.init_journal(User.find(12379))
      i.update_attribute(:status_id, Setting.plugin_export_to_vale_sap_robot['measurement_robot_status_id'])
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

    ImportMeasurementJob.perform_later(@attachment.diskfile, User.current.id)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), notice: l(:email_will_be_send_when_finish) and return
  end

  protected

  def custom_values_joins_query(table_alias, setting_id)
    custom_fields_ids = Array.wrap(Setting.plugin_export_to_vale_sap_robot["measurement_#{setting_id}"]).join(', ')
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

  def contratos_joins_query(table_alias, campo_join)
    "left join contratos #{table_alias} on #{table_alias}.contrato = #{campo_join}.value"
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
