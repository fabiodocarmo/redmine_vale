class ExportToValeRpaRobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def create
    issues = ValeExportReplicaIssue
                  .where(project_id: @project.id)
                  .where(status_id: Setting.plugin_export_to_vale_sap_robot['rpa_wating_status_id'])
                  .where(tracker_id: Setting.plugin_export_to_vale_sap_robot['rpa_tracker_id'])
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
                  .joins(custom_values_joins_query('valor_inss', 'valor_inss_id'))
                  .joins(custom_values_joins_query('tipo_documento', 'tipo_documento_id'))
                  .select('issues.id::text idsv_notas')
                  .select('to_char(nullif(postagem.value, \'\')::date, \'DD.MM.YYYY\') "Data de Postagem"')
                  .select('empresa.value "Empresa"')
                  .select('cv_cnpj_fornecedor.value "CNPJ Fornecedor"')
                  .select('to_char(nullif(emissao.value, \'\')::date, \'DD.MM.YYYY\') "Emissão"')
                  .select('to_char(nullif(vencimento.value, \'\')::date, \'DD.MM.YYYY\') "Vencimento"')
                  .select('LTRIM(referencia.value, \'0\') "Referência"')
                  .select('valor_total_nf.value "Valor Total NF-e"')
                  .select('null "Categoria"')
                  .select('pedido.value "Pedido"')
                  .select('frs.value "Número da FRS"')
                  .select('rf.value "RF"')
                  .select('null "Template"')
                  .select('null "Erro Template"')
                  .select('null "Log"')
                  .select('null "Mensagem"')
                  .select('valor_inss.value "Valor do INSS"')
                  .select('tipo_documento.value as "Tipo de Documento"')
                  .select('issues.tracker_id as "Tracker"')
                  .order(:id)
                  
    filename = ExportToValeSapRobot::Services::ImportNfs.export_utilities_rpa_template(issues, ['idsv_notas'      ,
                                                                                                'Data de Postagem',
                                                                                                'Empresa'         ,
                                                                                                'CNPJ Fornecedor' ,
                                                                                                'Emissão'         ,
                                                                                                'Vencimento'      ,
                                                                                                'Referência'      ,
                                                                                                'Valor Total NF-e',
                                                                                                'Categoria'       ,
                                                                                                'Pedido'          ,
                                                                                                'Número da FRS'   ,
                                                                                                'RF'              ,
                                                                                                'Template'        ,
                                                                                                'Erro Template'   ,
                                                                                                'Log'             ,
                                                                                                'Mensagem'        ,
                                                                                                'Valor do INSS'])
    send_file(filename, filename: 'template_robo_rpa.xlsx', type: "application/vnd.ms-excel")

    Issue.where(id: issues.map(&:idsv_notas)).each do |i|
      i.init_journal(User.current)
      i.update_attribute(:status_id, Setting.plugin_export_to_vale_sap_robot['rpa_robot_status_id'])
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

    ImportRpaJob.perform_later(@attachment.diskfile, User.current.id)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), notice: l(:email_will_be_send_when_finish) and return
  end

  protected

  def custom_values_joins_query(table_alias, setting_id)
    custom_fields_ids = Array.wrap(Setting.plugin_export_to_vale_sap_robot["rpa_#{setting_id}"]).join(', ')
    custom_fields_ids = 'null' if custom_fields_ids.blank?
    "left join custom_values #{table_alias} on #{table_alias}.customized_id = issues.id and #{table_alias}.customized_type = 'Issue' and #{table_alias}.custom_field_id in (#{custom_fields_ids})"
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
