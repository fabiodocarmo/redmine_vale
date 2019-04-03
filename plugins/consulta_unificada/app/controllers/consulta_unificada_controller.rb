# encoding: UTF-8
class ConsultaUnificadaController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required
  skip_before_filter :verify_authenticity_token

  accept_api_auth :index, :show, :create, :update, :destroy

  def retrieve_url_to_consultanf
    issue_id = params[:issue]
    issue = Issue.find(issue_id)
    @custom_field_cpf_cnpf = CustomField.where(name:'CNPJ/CPF').first
    @custom_field_nf = CustomField.where(name:'Número da Nota Fiscal').first
    url = Setting.plugin_consulta_unificada[:url_consulta]
    puts url[url.length-1]
    puts url.length
    if url[url.length-1] != "/"
      url = url + "/"
    end
    url = url + "app/"
    url = url + "?cnpj="
    url = url + CustomValue.where(customized_id:issue_id).where(custom_field_id:@custom_field_cpf_cnpf).first.value

    if issue.show_url_deposito?
      url = url + "#!relatorio_deposito"
    elsif issue.show_url_nf?
      if issue.has_valid_nf?
        url = url + "&notaFiscal="
        url = url + CustomValue.where(customized_id:issue_id).where(custom_field_id:@custom_field_nf).first.value
      end
      url = url + "#!detalhamento_nf"
    else
      redirect_to issue_path(issue.id)
    end

    redirect_to url
  end

  def nf_status
    nf_status = NfStatus.find(params['nf_status_id'])
    render :json => nf_status.to_json
  end

  def consultanf_notas
    @param = params['cnpj']
    return unless @param
    @cnpj_list = @param.split(',')
    @custom_field_cpf_cnpf = CustomField.where(name:'CNPJ/CPF').first
    puts params[:cnpj]
    puts @cnpj_list
    @cnpj_hash_list = []
    @cnpj_list.each do |cnpj|
      CustomValue.where(customized_type:'Issue').where(custom_field_id:@custom_field_cpf_cnpf).where(value:cnpj).each do |custom_value|
        issue = Issue.includes([:relations_to]).where(issue_relations: {issue_to_id:nil}).where(id:custom_value.customized_id).first
        next unless issue
        @nota_fiscal = issue.nf_number
        if @nota_fiscal
          h = {:cnpj => custom_value.value, :nota_fiscal => @nota_fiscal, :issue_id => custom_value.customized_id, :issue_title => issue.subject, :issue_url => issue_url(issue.id), :public_issue_url => issue_url(issue.id)}
          @cnpj_hash_list << h
        end
      end
    end
    render :json => @cnpj_hash_list
  end
end
