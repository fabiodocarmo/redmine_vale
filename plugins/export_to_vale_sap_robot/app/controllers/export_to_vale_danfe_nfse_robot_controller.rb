class ExportToValeDanfeNfseRobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def create
    issues = ValeExportReplicaIssue.where(project_id: @project.id)
                  .where(status_id: Setting.plugin_export_to_vale_sap_robot['danfe_nfse_wating_status_id'])
                  .where(tracker_id: [
                      Setting.plugin_export_to_vale_sap_robot['danfe_frs_tracker_id'],
                      Setting.plugin_export_to_vale_sap_robot['danfe_sps_tracker_id']
                  ])
                  .joins(custom_values_joins_query('empresa', 'empresa_id'))
                  .joins(custom_values_joins_query('cv_cnpj_vale', 'cnpj_vale_id'))
                  .joins(custom_values_joins_query('cv_cnpj_fornecedor', 'cnpj_fornecedor_id'))
                  .joins(custom_values_joins_query('emissao', 'emissao_id'))
                  .joins(custom_values_joins_query('referencia', 'referencia_id'))
                  .joins(custom_values_joins_query('serie', 'serie_id'))
                  .joins(custom_values_joins_query('valor_total_nf', 'valor_total_nf_id'))
                  .joins(custom_values_joins_query('numero_rf', 'numero_rf_id'))
                  .joins(custom_values_joins_query('pedido', 'pedido_id'))
                  .joins(custom_values_joins_query('cv_grid_linhas_pedido', 'cv_grid_linhas_pedido_id'))
                  .joins(custom_values_joins_query('texto', 'texto_id'))
                  .joins(custom_values_joins_query('cv_data_basica', 'cv_data_basica_id'))
                  .joins(custom_values_joins_query('cv_tipo_documento_cte_os', 'cv_tipo_documento_cte_os_id'))
                  .joins(custom_values_joins_query('base_calculo_inss', 'base_calculo_inss_id'))
                  .joins(custom_values_joins_query('base_calculo_iss', 'base_calculo_iss_id'))
                  .joins(custom_values_joins_query('aliquota_inss', 'aliquota_inss_id'))
                  .joins(custom_values_joins_query('aliquota_iss', 'aliquota_iss_id'))
                  .joins(custom_values_joins_query('optante_simples', 'optante_simples_id'))
                  .joins(custom_values_joins_query('chave_acesso', 'chave_acesso_id'))
                  .joins(custom_values_joins_query('hora_emissao', 'hora_emissao_id'))
                  .joins(custom_values_joins_query('numero_protocolo', 'numero_protocolo_id'))
                  .select('issues.id')
                  .select('issues.id as "ID"')
                  .select('issues.id as "OBSERVACOES"')
                  .select('concat(\'\'\'\', cv_cnpj_vale.value) as "CNPJ_VALE"')
                  .select('\'Fatura\' as "OPERACAO"')
                  .select('concat(\'\'\'\', cv_cnpj_fornecedor.value) as "CNPJ_FORNECEDOR"')
                  .select('to_char(emissao.value::date, \'\'\'DD.MM.YYYY\') as "DATA_FATURA"')
                  .select('to_char(now(), \'\'\'DD/MM/YYYY\') as "DATA_LANCAMENTO"')
                  .select('\'\' || LPAD(referencia.value,9,\'0\') as "REFERENCIA"')
                  .select('\'\' || serie.value as "SERIE"')
                  .select('valor_total_nf.value as "MONTANTE"')
                  .select('\'\' as "TIPO_FILTRO"')
                  .select('pedido.value as "NUMERO_PEDIDO"')
                  .select('numero_rf.value as "NUMERO_RF"')
                  .select('\'\' as "NUMERO_LINHAS"')
                  .select('\'\' as "CATEGORIA_NF"')
                  .select('texto.value as "TEXTO"')
                  .select('\'\' as "CONDICAO_PAGAMENTO"')
                  .select('to_char(cv_data_basica.value::date, \'\'\'DD/MM/YYYY\') as "DATA_BASICA"')
                  .select('\'\' as "BLOQUEIO_PAGAMENTO"')
                  .select('\'\' as "FORMA_PAGAMENTO"')
                  .select('\'\' as "ATRIBUICAO"')
                  .select('\'\' as "TEXTO_CABECALHO"')
                  .select('cv_cnpj_fornecedor.value as "FORNECEDOR_PARCEIRO"')
                  .select('\'\' as "REFERENCIA_PAGAMENTO"')
                  .select('chave_acesso.value as "CHAVE"')
                  .select('numero_protocolo.value as "PROTOCOLO_AUTORIZACAO"')
                  .select('to_char(emissao.value::date, \'\'\'DD.MM.YYYY\') as "DATA_EMISSAO"')
                  .select('hora_emissao.value as "HORA_EMISSAO"')
                  .select('\'\' as "REGIAO"')
                  .select('\'\' as "EXERC_CONTABIL"')
                  .select('\'\' as "MES_DOCUMENTO"')
                  .select('\'\' as "NUM_CNPJ"')
                  .select('\'\' as "MODELO_NF"')
                  .select('\'\' as "SERIE_CTE"')
                  .select('\'\' as "NUMERO_NF"')
                  .select('\'\' as "TP_EMISSAO"')
                  .select('\'\' as "NUM_ALEATORIO"')
                  .select('\'\' as "DIG_VERIF"')
                  .select('cv_grid_linhas_pedido.value as "grid_linhas_pedido"')
                  .select('coalesce(cv_tipo_documento_cte_os.value, \'0\') as "tipo_documento"')
                  .select('valor_total_nf.value as "valor_documento"')
                  .select('base_calculo_iss.value as "base_calculo_iss"')
                  .select('base_calculo_inss.value as "base_calculo_inss"')
                  .select('aliquota_inss.value as "aliquota_inss"')
                  .select('aliquota_iss.value as "aliquota_iss"')
                  .select('optante_simples.value as "optante_simples"')
                  .select('issues.tracker_id')
                  .select('chave_acesso.value as "chave_acesso"')
                  .order(:id)

    filename = ExportToValeSapRobot::Services::ImportNfs.export_danfe_nfse_template(issues, ['ID',
                                                                                         'OBSERVACOES',
                                                                                         'CNPJ_VALE',
                                                                                         'OPERACAO',
                                                                                         'CNPJ_FORNECEDOR',
                                                                                         'DATA_FATURA',
                                                                                         'DATA_LANCAMENTO',
                                                                                         'REFERENCIA',
                                                                                         'SERIE',
                                                                                         'MONTANTE',
                                                                                         'TIPO_FILTRO',
                                                                                         'NUMERO_PEDIDO',
                                                                                         'NUMERO_RF',
                                                                                         'NUMERO_LINHAS',
                                                                                         'CATEGORIA_NF',
                                                                                         'TEXTO',
                                                                                         'CONDICAO_PAGAMENTO',
                                                                                         'DATA_BASICA',
                                                                                         'BLOQUEIO_PAGAMENTO',
                                                                                         'FORMA_PAGAMENTO',
                                                                                         'ATRIBUICAO',
                                                                                         'TEXTO_CABECALHO',
                                                                                         'FORNECEDOR_PARCEIRO',
                                                                                         'REFERENCIA_PAGAMENTO',
                                                                                         'CHAVE',
                                                                                         'PROTOCOLO_AUTORIZACAO',
                                                                                         'DATA_EMISSAO',
                                                                                         'HORA_EMISSAO',
                                                                                         'REGIAO',
                                                                                         'EXERC_CONTABIL',
                                                                                         'MES_DOCUMENTO',
                                                                                         'NUM_CNPJ',
                                                                                         'MODELO_NF',
                                                                                         'SERIE',
                                                                                         'NUMERO_NF',
                                                                                         'TP_EMISSAO',
                                                                                         'NUM_ALEATORIO',
                                                                                         'DIG_VERIF'],
                                                                                        ['ID_LINHA',
                                                                                         'DESCRICAO_IMPOSTO',
                                                                                         'MONTANTE_BASICO',
                                                                                         'TAXA_IMPOSTO',
                                                                                         'FLAG_MONTANTE_TAXA'])
    send_file(filename, filename: 'template_robo_danfe_nfse.xlsx', type: "application/vnd.ms-excel")

    Issue.where(id: issues.map(&:id)).each do |i|
      i.init_journal(User.current)
      i.update_attribute(:status_id, Setting.plugin_export_to_vale_sap_robot['danfe_nfse_robot_status_id'])
    end
  end

  def update_ok
    log_type = 'ok'
    issue_id_col = 1
    journal_msg_col = nil
    custom_field_cols = []
    custom_field_cols << {id: Setting.plugin_export_to_vale_sap_robot['danfe_nfse_miro'], col: -2}
    current_status_id = Setting.plugin_export_to_vale_sap_robot['danfe_nfse_robot_status_id']
    new_status_id = Setting.plugin_export_to_vale_sap_robot['danfe_nfse_success_robot_status_id']
    flash_hash = ExportToValeSapRobot::Services::ImportNfs.
      update_issues_by_log(params, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), flash_hash
  end

  def update_error
    log_type = 'error'
    issue_id_col = 1
    journal_msg_col = -1
    custom_field_cols = []
    current_status_id = Setting.plugin_export_to_vale_sap_robot['danfe_nfse_robot_status_id']
    new_status_id = Setting.plugin_export_to_vale_sap_robot['danfe_nfse_error_robot_status_id']
    flash_hash = ExportToValeSapRobot::Services::ImportNfs.
      update_issues_by_log(params, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), flash_hash
  end

  protected

  def custom_values_joins_query(table_alias, setting_id)
    custom_fields_ids = Array.wrap(Setting.plugin_export_to_vale_sap_robot["danfe_nfse_#{setting_id}"]).join(', ')
    custom_fields_ids = 'null' if custom_fields_ids.blank?
    "left join custom_values #{table_alias} on #{table_alias}.customized_id = issues.id and #{table_alias}.customized_type = 'Issue' and #{table_alias}.custom_field_id in (#{custom_fields_ids})"
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
