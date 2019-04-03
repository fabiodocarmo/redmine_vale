class ExportToValeDanfeCompaniesRobotController < ApplicationController
  unloadable
  before_filter :find_project, :authorize

  def index
  end

  def create
    issues = ValeExportReplicaIssue.where(project_id: @project.id, status_id: Setting.plugin_export_to_vale_sap_robot['danfe_wating_status_id'])
                  .joins("left join custom_values cv_cnpj_fornecedor on cv_cnpj_fornecedor.customized_id = issues.id and cv_cnpj_fornecedor.customized_type = 'Issue' and cv_cnpj_fornecedor.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_cnpj_fornecedor_id']}'")
                  .joins("left join custom_values valor_total_nf on valor_total_nf.customized_id = issues.id and valor_total_nf.customized_type = 'Issue' and valor_total_nf.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_valor_total_nf_id']}'")
                  .joins("left join custom_values referencia on referencia.customized_id = issues.id and referencia.customized_type = 'Issue' and referencia.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_referencia_id']}'")
                  .joins("left join custom_values pedido on pedido.customized_id = issues.id and pedido.customized_type = 'Issue' and pedido.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_pedido_id']}'")
                  .joins("left join custom_values emissao on emissao.customized_id = issues.id and emissao.customized_type = 'Issue' and emissao.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_emissao_id']}'")
                  .joins("left join custom_values vencimento on vencimento.customized_id = issues.id and vencimento.customized_type = 'Issue' and vencimento.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_vencimento_id']}'")
                  .joins("left join custom_values tipo_cadastro on tipo_cadastro.customized_id = issues.id and tipo_cadastro.customized_type = 'Issue' and tipo_cadastro.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_tipo_cadastro_id']}'")
                  .joins("left join custom_values empresa on empresa.customized_id = issues.id and empresa.customized_type = 'Issue' and empresa.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_empresa_id']}'")
                  .joins("left join custom_values codigo_barras on codigo_barras.customized_id = issues.id and codigo_barras.customized_type = 'Issue' and codigo_barras.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_codigo_barras']}'")
                  .joins("left join custom_values chave_acesso on chave_acesso.customized_id = issues.id and chave_acesso.customized_type = 'Issue' and chave_acesso.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_chave_acesso']}'")
                  .joins("left join custom_values postagem on postagem.customized_id = issues.id and postagem.customized_type = 'Issue' and postagem.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_postagem']}'")
                  .joins("left join custom_values tipo_documento on tipo_documento.customized_id = issues.id and tipo_documento.customized_type = 'Issue' and tipo_documento.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['danfe_tipo_documento']}'")
                  .select('\'\' || issues.id as idsv_notas')
                  .select('\'\' || issues.id as id_senha')
                  .select('\'\' || cv_cnpj_fornecedor.value as "CNPJ Fornecedor"')
                  .select('\'\' || emissao.value as "Emissão"')
                  .select('valor_total_nf.value as "Valor Total NF-e"')
                  .select('\'\' || ltrim(RIGHT(referencia.value,6), \'0\') as "Referência"')
                  .select('\'\' || pedido.value as "Pedido"')
                  .select('to_char(nullif(vencimento.value, \'\')::date, \'\'\'DD.MM.YYYY\') as "Vencimento"')
                  .select('\'\' || empresa.value as "Empresa"')
                  .select("\'\' || case tipo_cadastro.value 
                    when 'Crédito em Conta' then 'S'
                    when 'Boleto' then 'B'
                    when 'Débito Automático' then 'B'
                    when 'Regularização' then 'B'
                    when 'Conta Poupança' then 'B'
                    when 'Cheque Administrativo' then 'B'
                    end as \"Metodo Pgto\"")
                  .select('null as "Bloqueio"')
                  .select('chave_acesso.value as "Chave de Acesso"')
                  .select('codigo_barras.value as "Código de Barras"')
                  .select('null as "Template"')
                  .select('null as "Erro Template"')
                  .select('null as "Log"')
                  .select('null as "Mensagem"')
                  .select('to_char(nullif(postagem.value, \'\')::date, \'\'\'DD.MM.YYYY\') as "Data de Postagem"')
                  .select('null as "Categoria"')
                  .select('tipo_documento.value as "Tipo de Documento"')
                  .select('issues.tracker_id as "Tracker"')
                  .order(:id)

    filename = ExportToValeSapRobot::Services::ImportNfs.export_transmission_companies_template(issues, ['idsv_notas'         ,
                                                                                                         'id_senha'           ,
                                                                                                         'CNPJ Fornecedor'    ,
                                                                                                         'Emissão'            ,
                                                                                                         'Valor Total NF-e'   ,
                                                                                                         'Referência'         ,
                                                                                                         'Pedido'             ,
                                                                                                         'Vencimento'         ,
                                                                                                         'Metodo Pgto'        ,
                                                                                                         'Bloqueio'           ,
                                                                                                         'Empresa'            ,
                                                                                                         'Chave de Acesso'    ,
                                                                                                         'Template'           ,
                                                                                                         'Erro Template'      ,
                                                                                                         'Log'                ,
                                                                                                         'Mensagem'           ,
                                                                                                         'Código de Barras'   ,
                                                                                                         'Data de Postagem'   ,
                                                                                                         'Categoria'])

    send_file(filename, filename: 'template_robo_danfe.xlsx', type: "application/vnd.ms-excel")

    Issue.where(id: issues.map(&:id_senha)).each do |i|
      i.init_journal(User.current)
      i.update_attribute(:status_id, Setting.plugin_export_to_vale_sap_robot['danfe_robot_status_id'])
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

    ImportDanfeJob.perform_later(@attachment.diskfile, User.current.id)

    redirect_to url_for(action: :index, controller: params[:controller], project_id: params[:project_id]), notice: l(:email_will_be_send_when_finish) and return
  end

  protected

  def find_project
    @project = Project.find(params[:project_id])
  end
end
