class ExportToValeRentsRobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def create
    issues = ValeExportReplicaIssue
                  .where(status_id: Setting.plugin_export_to_vale_sap_robot['rents_wating_status_id'])
                  .where(tracker_id: Setting.plugin_export_to_vale_sap_robot['rents_tracker_id'])
                  .joins(custom_values_joins_query('postagem', 'postagem_id'))
                  .joins(custom_values_joins_query('empresa', 'empresa_id'))
                  .joins(custom_values_joins_query('cv_cnpj_fornecedor', 'cnpj_fornecedor_id'))
                  .joins(custom_values_joins_query('emissao', 'emissao_id'))
                  .joins(custom_values_joins_query('vencimento', 'vencimento_id'))
                  .joins(custom_values_joins_query('referencia', 'referencia_id'))
                  .joins(custom_values_joins_query('valor_total_nf', 'valor_total_nf_id'))
                  .joins(custom_values_joins_query('pedido', 'pedido_id'))
                  .joins(custom_values_joins_query('frs', 'frs_id'))
                  .joins(custom_values_joins_query('rf', 'rf_id'))
                  .joins(custom_values_joins_query('pagamento', 'pagamento_id'))
                  .joins(custom_values_joins_query('codigo_barras', 'codigo_barras_id'))
                  .joins(custom_values_joins_query('tipo_documento', 'tipo_documento_id'))
                  .select('\'\' || issues.id as idsv_notas')
                  .select('to_char(nullif(postagem.value, \'\')::date, \'DD.MM.YYYY\') as "Data de Postagem"')
                  .select('\'\' || empresa.value as "Empresa"')
                  .select('\'\' || cv_cnpj_fornecedor.value as "CNPJ Fornecedor"')
                  .select('to_char(nullif(emissao.value, \'\')::date, \'DD.MM.YYYY\') as "Emissão"')
                  .select('to_char(nullif(vencimento.value, \'\')::date, \'DD.MM.YYYY\') as "Vencimento"')
                  .select('ltrim(referencia.value, \'0\') "Referência"')
                  .select('valor_total_nf.value as "Valor Total NF-e"')
                  .select('null as "Categoria"')
                  .select('\'\' || pedido.value as "Pedido"')
                  .select('\'\' || frs.value as "Número da FRS"')
                  .select('\'\' || rf.value as "RF"')
                  .select("\'\' || case pagamento.value 
                    when 'Crédito em Conta' then 'S'
                    when 'Boleto' then 'B'
                    when 'Débito Automático' then 'B'
                    when 'Regularização' then 'B'
                    when 'Conta Poupança' then 'B'
                    when 'Cheque Administrativo' then 'B'
                    end as \"Método de Pagamento\"")
                  .select('\'\' || pagamento.value as "Tipo Cadastro"')
                  .select('null as "Template"')
                  .select('null as "Erro Template"')
                  .select('null as "Log"')
                  .select('null as "Mensagem"')
                  .select('\'\' || codigo_barras.value as "Código de Barras"')
                  .select('tipo_documento.value as "Tipo de Documento"')
                  .select('issues.tracker_id as "Tracker"')
                  .select('null as "ID Débito Automático"')
                  .select('null as "Bloqueio"')
                  .select('null as "Moeda"')
                  .order(:id)

    filename = ExportToValeSapRobot::Services::ImportNfs.export_utilities_rents_template(issues, [
                                                                                                  'Empresa'             ,
                                                                                                  'CNPJ Fornecedor'     ,
                                                                                                  'Emissão'             ,
                                                                                                  'Vencimento'          ,
                                                                                                  'Referência'          ,
                                                                                                  'Valor Total NF-e'    ,
                                                                                                  'Categoria'           ,
                                                                                                  'Pedido'              ,
                                                                                                  'Tipo Cadastro'       ,
                                                                                                  'Método de Pagamento' ,
                                                                                                  'Bloqueio'            ,
                                                                                                  'Template'            ,
                                                                                                  'Erro Template'       ,
                                                                                                  'Log'                 ,
                                                                                                  'Mensagem'            ,
                                                                                                  'Código de Barras'    ,
                                                                                                  'Moeda'               ,
                                                                                                  'ID Débito Automático',                             
                                                                                                  'Data de Postagem'    ,
                                                                                                  'Número da FRS'       ,
                                                                                                  'RF'                  ,
                                                                                                  'idsv_notas'          ,
                                                                                                  ])
    send_file(filename, filename: 'template_robo_alugueis.xlsx', type: "application/vnd.ms-excel")

    Issue.where(id: issues.map(&:idsv_notas)).each do |i|
      i.init_journal(User.current)
      i.update_attribute(:status_id, Setting.plugin_export_to_vale_sap_robot['rents_robot_status_id'])
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

    ImportRentsJob.perform_later(@attachment.diskfile, User.current.id)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), notice: l(:email_will_be_send_when_finish) and return
  end

  protected

  def custom_values_joins_query(table_alias, setting_id)
    custom_fields_ids = Array.wrap(Setting.plugin_export_to_vale_sap_robot["rents_#{setting_id}"]).join(', ')
    custom_fields_ids = 'null' if custom_fields_ids.blank?
    "left join custom_values #{table_alias} on #{table_alias}.customized_id = issues.id and #{table_alias}.customized_type = 'Issue' and #{table_alias}.custom_field_id in (#{custom_fields_ids})"
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
