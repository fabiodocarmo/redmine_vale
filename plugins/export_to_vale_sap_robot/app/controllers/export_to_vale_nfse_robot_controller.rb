class ExportToValeNfseRobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def create
    issues = ValeExportReplicaIssue.where(project_id: @project.id)
                  .where(status_id: Setting.plugin_export_to_vale_sap_robot['nfse_wating_status_id'])
                  .where(tracker_id: [
                      Setting.plugin_export_to_vale_sap_robot['nfse_rf_tracker'],
                      Setting.plugin_export_to_vale_sap_robot['recibo_fatura_nd_tracker'],
                      Setting.plugin_export_to_vale_sap_robot['nfse_sps_tracker'],
                      Setting.plugin_export_to_vale_sap_robot['recibo_fatura_nd_sps_tracker'],
                      Setting.plugin_export_to_vale_sap_robot['nfse_sedex_rf_tracker'],
                      Setting.plugin_export_to_vale_sap_robot['nfse_sedex_sps_tracker']
                  ])
                  .joins("left join custom_values cv_cnpj_vale on cv_cnpj_vale.customized_id = issues.id and cv_cnpj_vale.customized_type = 'Issue' and cv_cnpj_vale.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_cnpj_vale']}'")
                  .joins("left join custom_values cv_cnpj_fornecedor on cv_cnpj_fornecedor.customized_id = issues.id and cv_cnpj_fornecedor.customized_type = 'Issue' and cv_cnpj_fornecedor.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_cnpj_fornecedor']}'")
                  .joins("left join custom_values cv_data_fatura on cv_data_fatura.customized_id = issues.id and cv_data_fatura.customized_type = 'Issue' and cv_data_fatura.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_data_fatura']}'")
                  .joins("left join custom_values cv_referencia_nfse on cv_referencia_nfse.customized_id = issues.id and cv_referencia_nfse.customized_type = 'Issue' and cv_referencia_nfse.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_referencia']}'")
                  .joins("left join custom_values cv_referencia_recibo_fatura_nd on cv_referencia_recibo_fatura_nd.customized_id = issues.id and cv_referencia_recibo_fatura_nd.customized_type = 'Issue' and cv_referencia_recibo_fatura_nd.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_referencia_recibo_fatura_nd']}'")
                  .joins("left join custom_values cv_montante on cv_montante.customized_id = issues.id and cv_montante.customized_type = 'Issue' and cv_montante.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_montante']}'")
                  .joins("left join custom_values cv_numero_pedido on cv_numero_pedido.customized_id = issues.id and cv_numero_pedido.customized_type = 'Issue' and cv_numero_pedido.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['sps_numero_pedido']}' and issues.tracker_id in (#{[Setting.plugin_export_to_vale_sap_robot['recibo_fatura_nd_sps_tracker'], Setting.plugin_export_to_vale_sap_robot['nfse_sps_tracker'],Setting.plugin_export_to_vale_sap_robot['nfse_sedex_sps_tracker']].join(',')})")
                  .joins("left join custom_values cv_numero_rf on cv_numero_rf.customized_id = issues.id and cv_numero_rf.customized_type = 'Issue' and cv_numero_rf.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_numero_rf']}'")
                  .joins("left join custom_values cv_grid_linhas_pedido on cv_grid_linhas_pedido.customized_id = issues.id and cv_grid_linhas_pedido.customized_type = 'Issue' and cv_grid_linhas_pedido.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['sps_grid_linhas_pedido']}'")
                  .joins("left join custom_values cv_tipo_documento_recibo_fatura_nd on cv_tipo_documento_recibo_fatura_nd.customized_id = issues.id and cv_tipo_documento_recibo_fatura_nd.customized_type = 'Issue' and cv_tipo_documento_recibo_fatura_nd.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_tipo_documento_recibo_fatura_nd']}'")
                  .joins("left join custom_values cv_inscricao_municipal on cv_inscricao_municipal.customized_id = issues.id and cv_inscricao_municipal.customized_type = 'Issue' and cv_inscricao_municipal.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_inscricao_municipal']}'")
                  .joins("left join custom_values cv_municipio on cv_municipio.customized_id = issues.id and cv_municipio.customized_type = 'Issue' and cv_municipio.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_municipio']}'")
                  .joins("left join custom_values cv_texto on cv_texto.customized_id = issues.id and cv_texto.customized_type = 'Issue' and cv_texto.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_texto']}'")
                  .joins("left join custom_values cv_data_basica on cv_data_basica.customized_id = issues.id and cv_data_basica.customized_type = 'Issue' and cv_data_basica.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_data_basica']}'")
                  .joins("left join custom_values cv_base_calculo_iss on cv_base_calculo_iss.customized_id = issues.id and cv_base_calculo_iss.customized_type = 'Issue' and cv_base_calculo_iss.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_base_calculo_iss']}'")
                  .joins("left join custom_values cv_base_calculo_inss on cv_base_calculo_inss.customized_id = issues.id and cv_base_calculo_inss.customized_type = 'Issue' and cv_base_calculo_inss.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_base_calculo_inss']}'")
                  .joins("left join custom_values cv_aliquota_iss on cv_aliquota_iss.customized_id = issues.id and cv_aliquota_iss.customized_type = 'Issue' and cv_aliquota_iss.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_aliquota_iss']}'")
                  .joins("left join custom_values cv_aliquota_inss on cv_aliquota_inss.customized_id = issues.id and cv_aliquota_inss.customized_type = 'Issue' and cv_aliquota_inss.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_aliquota_inss']}'")
                  .joins("left join custom_values cv_optante_simples on cv_optante_simples.customized_id = issues.id and cv_optante_simples.customized_type = 'Issue' and cv_optante_simples.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_optante_simples']}'")
                  .joins("left join custom_values cv_sedex_tipo_nota on cv_sedex_tipo_nota.customized_id = issues.id and cv_sedex_tipo_nota.customized_type = 'Issue' and cv_sedex_tipo_nota.custom_field_id = #{Setting.plugin_export_to_vale_sap_robot['sedex_tipo_nota']}")
                  .select('issues.id as "ID"')
                  .select('issues.id as "OBSERVACOES"')
                  .select('concat(\'\'\'\', cv_cnpj_vale.value) as "CNPJ_VALE"')
                  .select('\'Fatura\' as "OPERACAO"')
                  .select('concat(\'\'\'\', cv_cnpj_fornecedor.value) as "CNPJ_FORNECEDOR"')
                  .select('to_char(nullif(cv_data_fatura.value, \'\')::date, \'\'\'DD/MM/YYYY\') as "DATA_FATURA"')
                  .select('to_char(now(), \'\'\'DD/MM/YYYY\') as "DATA_LANCAMENTO"')
                  .select('RIGHT(coalesce(cv_referencia_nfse.value, cv_referencia_recibo_fatura_nd.value),6) as "REFERENCIA"')
                  .select('cv_montante.value as "MONTANTE"')
                  .select('\'\' as "TIPO_FILTRO"')
                  .select('cv_numero_pedido.value as "NUMERO_PEDIDO"')
                  .select('cv_numero_rf.value as "NUMERO_RF"')
                  .select('\'\' as "NUMERO_LINHAS"')
                  .select('\'\' as "CATEGORIA_NF"')
                  .select('cv_inscricao_municipal.value as "INCRICAO_MUNICIPAL"')
                  .select('cv_municipio.value as "MUNICIPIO"')
                  .select('\'\' as "IVA"')
                  .select('\'false\' as "FLAG_IVA"')
                  .select('\'\' as "MUNICIPIO_ISS"')
                  .select('\'false\' as "FLAG_MUNICIPIO_ISS"')
                  .select('cv_texto.value as "TEXTO"')
                  .select('\'\' as "CONDICAO_PAGAMENTO"')
                  .select('to_char(nullif(cv_data_basica.value, \'\')::date, \'\'\'DD/MM/YYYY\') as "DATA_BASICA"')
                  .select('\'\' as "BLOQUEIO_PAGAMENTO"')
                  .select('\'\' as "FORMA_PAGAMENTO"')
                  .select('\'\' as "ATRIBUICAO"')
                  .select('\'RoboNFSERVIÇO\' as "TEXTO_CABECALHO"')
                  .select('cv_cnpj_fornecedor.value as "FORNECEDOR_PARCEIRO"')
                  .select('\'\' as "REFERENCIA_PAGAMENTO"')
                  .select('\'\' as "MEMORIZAR_MIRO"')
                  .select('\'true\' as "IGNORAR_CLAS_FISCAL"')
                  .select('issues.tracker_id')
                  .select('cv_grid_linhas_pedido.value as "grid_linhas_pedido"')
                  .select('coalesce(cv_tipo_documento_recibo_fatura_nd.value, cv_sedex_tipo_nota.value, (cv_cnpj_fornecedor.value ~ \'^\\d{11}$\')::int::text, \'0\') as "tipo_documento"')
                  .select('cv_montante.value as "valor_documento"')
                  .select('cv_base_calculo_iss.value as "base_calculo_iss"')
                  .select('cv_base_calculo_inss.value as "base_calculo_inss"')
                  .select('cv_aliquota_iss.value as "aliquota_iss"')
                  .select('cv_aliquota_inss.value as "aliquota_inss"')
                  .select('cv_optante_simples.value as "optante_simples"')
                  .order(:id)

    filename = ExportToValeSapRobot::Services::ImportNfs.export_nfse_template(issues,
                %w( ID
                    OBSERVACOES
                    CNPJ_VALE
                    OPERACAO
                    CNPJ_FORNECEDOR
                    DATA_FATURA
                    DATA_LANCAMENTO
                    REFERENCIA
                    MONTANTE
                    TIPO_FILTRO
                    NUMERO_PEDIDO
                    NUMERO_RF
                    NUMERO_LINHAS
                    CATEGORIA_NF
                    INCRICAO_MUNICIPAL
                    MUNICIPIO
                    IVA
                    FLAG_IVA
                    MUNICIPIO_ISS
                    FLAG_MUNICIPIO_ISS
                    TEXTO
                    CONDICAO_PAGAMENTO
                    DATA_BASICA
                    BLOQUEIO_PAGAMENTO
                    FORMA_PAGAMENTO
                    ATRIBUICAO
                    TEXTO_CABECALHO
                    FORNECEDOR_PARCEIRO
                    REFERENCIA_PAGAMENTO
                    MEMORIZAR_MIRO
                    IGNORAR_CLAS_FISCAL),
                %w( ID_LINHA
                    DESCRICAO_IMPOSTO
                    MONTANTE_BASICO
                    TAXA_IMPOSTO
                    FLAG_MONTANTE_TAXA
                    COD_CONTROLE)
    )
    Issue.where(id: issues.select("issues.id").map{|i| i.id}).update_all(status_id: Setting.plugin_export_to_vale_sap_robot['nfse_robot_status_id'])
    send_file(filename, filename: 'template_robo_nfse.xlsx', type: "application/vnd.ms-excel")
  end

  def update_ok
    log_type = 'ok'
    issue_id_col = 1
    journal_msg_col = nil
    custom_field_cols = []
    custom_field_cols << {id: Setting.plugin_export_to_vale_sap_robot['nfse_miro'], col: -2}
    current_status_id = Setting.plugin_export_to_vale_sap_robot['nfse_robot_status_id']
    new_status_id = Setting.plugin_export_to_vale_sap_robot['nfse_success_robot_status_id']
    flash_hash = ExportToValeSapRobot::Services::ImportNfs.
      update_issues_by_log(params, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), flash_hash
  end

  def update_error
    log_type = 'error'
    issue_id_col = 1
    journal_msg_col = -1
    custom_field_cols = []
    current_status_id = Setting.plugin_export_to_vale_sap_robot['nfse_robot_status_id']
    new_status_id = Setting.plugin_export_to_vale_sap_robot['nfse_error_robot_status_id']
    flash_hash = ExportToValeSapRobot::Services::ImportNfs.
      update_issues_by_log(params, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), flash_hash
  end

  protected
  def find_project
    @project = Project.find(params[:project_id])
  end
end
