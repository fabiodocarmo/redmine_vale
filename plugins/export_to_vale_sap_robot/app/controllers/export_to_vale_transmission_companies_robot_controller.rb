class ExportToValeTransmissionCompaniesRobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def create
    issues = ValeExportReplicaIssue
                  .where(project_id: @project.id.to_i) 
                  .where(status_id: Setting.plugin_export_to_vale_sap_robot['dine_wating_status_id'].to_i)
                  .where(tracker_id: Setting.plugin_export_to_vale_sap_robot['dine_tracker_id'].to_i)
                  .joins("left join custom_values cv_cnpj_fornecedor on cv_cnpj_fornecedor.customized_id = issues.id and cv_cnpj_fornecedor.customized_type = 'Issue' and cv_cnpj_fornecedor.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_cnpj_fornecedor_id']}'")
                  .joins("left join custom_values valor_total_nf on valor_total_nf.customized_id = issues.id and valor_total_nf.customized_type = 'Issue' and valor_total_nf.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_valor_total_nf_id']}'")
                  .joins("left join custom_values referencia on referencia.customized_id = issues.id and referencia.customized_type = 'Issue' and referencia.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_referencia_id']}'")
                  .joins("left join custom_values pedido on pedido.customized_id = issues.id and pedido.customized_type = 'Issue' and pedido.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_pedido_id']}'")
                  .joins("left join custom_values emissao on emissao.customized_id = issues.id and emissao.customized_type = 'Issue' and emissao.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_emissao_id']}'")
                  .joins("left join custom_values vencimento on vencimento.customized_id = issues.id and vencimento.customized_type = 'Issue' and vencimento.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_vencimento_id']}'")
                  .joins("left join custom_values metodo_pagamento on metodo_pagamento.customized_id = issues.id and metodo_pagamento.customized_type = 'Issue' and metodo_pagamento.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_metodo_pagamento_id']}'")
                  .joins("left join custom_values empresa on empresa.customized_id = issues.id and empresa.customized_type = 'Issue' and empresa.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_empresa_id']}'")
                  .joins("left join custom_values codigo_barras on codigo_barras.customized_id = issues.id and codigo_barras.customized_type = 'Issue' and codigo_barras.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_codigo_barras']}'")
                  .joins("left join custom_values postagem on postagem.customized_id = issues.id and postagem.customized_type = 'Issue' and postagem.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_postagem']}'")
                  .joins("left join custom_values tipo_documento on tipo_documento.customized_id = issues.id and tipo_documento.customized_type = 'Issue' and tipo_documento.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['dine_tipo_documento']}'")
                  .select('\'\' || issues.id as idsv_notas')
                  .select('\'\' || issues.id as id_senha')
                  .select('\'\' || empresa.value as "Empresa"')
                  .select('\'\' || cv_cnpj_fornecedor.value as "CNPJ Fornecedor"')
                  .select('to_char(nullif(emissao.value, \'\')::date, \'DD.MM.YYYY\') as "Emissão"')
                  .select('to_char(nullif(vencimento.value, \'\')::date, \'DD.MM.YYYY\') as "Vencimento"')
                  .select('\'\' || ltrim(RIGHT(referencia.value,6), \'0\') as "Referência"')
                  .select('\'\' || valor_total_nf.value as "Valor Total NF-e"')
                  .select('null as "Categoria"')
                  .select('\'\' || pedido.value as "Pedido"')
                  .select('\'\' || metodo_pagamento.value as "Tipo Cadastro"')
                  .select("\'\' || case metodo_pagamento.value 
                    when 'Crédito em Conta' then 'S'
                    when 'Boleto' then 'B'
                    when 'Débito Automático' then 'B'
                    when 'Regularização' then 'B'
                    when 'Conta Poupança' then 'B'
                    when 'Cheque Administrativo' then 'B'
                    end as \"Metodo Pgto\"")
                  .select('null as "Bloqueio"')
                  .select('null as "Template"')
                  .select('null as "Erro Template"')
                  .select('null as "Log"')
                  .select('null as "Mensagem"')
                  .select('\'\' || codigo_barras.value as "Código de Barras"')
                  .select('to_char(nullif(postagem.value, \'\')::date, \'DD.MM.YYYY\') as "Data de Postagem"')
                  .select('tipo_documento.value as "Tipo de Documento"')
                  .select('issues.tracker_id as "Tracker"')
                  .select('null as "FRS"')
                  .select('null as "Moeda"')
                  .order(:id)

    filename = ExportToValeSapRobot::Services::ImportNfs.export_transmission_companies_template(issues, [
                                                                                                         'Empresa'            ,
                                                                                                         'CNPJ Fornecedor'    ,
                                                                                                         'Emissão'            ,
                                                                                                         'Vencimento'         ,
                                                                                                         'Referência'         ,
                                                                                                         'Valor Total NF-e'   ,
                                                                                                         'Categoria'          ,
                                                                                                         'Pedido'             ,
                                                                                                         'Tipo Cadastro'      ,
                                                                                                         'Metodo Pgto'        ,
                                                                                                         'Bloqueio'           ,
                                                                                                         'Template'           ,
                                                                                                         'Erro Template'      ,
                                                                                                         'Log'                ,
                                                                                                         'Mensagem'           ,
                                                                                                         'Código de Barras'   ,
                                                                                                         'Moeda'              ,
                                                                                                         'FRS'                ,
                                                                                                         'idsv_notas'])

    send_file(filename, filename: 'template_robo_transmissoras.xlsx', type: "application/vnd.ms-excel")
    Issue.where(id: issues.map(&:id_senha)).each do |i|
      i.init_journal(User.current)
      i.update_attribute(:status_id, Setting.plugin_export_to_vale_sap_robot['dine_robot_status_id'])
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

    ImportTransmissionsJob.perform_later(@attachment.diskfile, User.current.id)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), notice: l(:email_will_be_send_when_finish) and return
  end

  protected

  def find_project
    @project = Project.find(params[:project_id])
  end
end
