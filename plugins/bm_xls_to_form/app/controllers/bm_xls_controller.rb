class BmXlsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def create
    # Make sure that API users get used to set this content type
    # as it won't trigger Rails' automatic parsing of the request body for parameters


    unless request.content_type == 'application/octet-stream'
      render :nothing => true, :status => 406
      return
    end

    tmp_file = "#{Rails.root}/tmp/uploaded.xlsx"
    id = 0
    while File.exists?(tmp_file) do
      tmp_file = "#{Rails.root}/tmp/uploaded-#{id}.xlsx"
      id += 1
    end

    # Save to temp file
    File.open(tmp_file, 'wb') do |f|
      f.write  request.body.read
      f.close
    end

    file_ext = BmXlsParser.get_file_extension(tmp_file)

    respond_to do |format|
      format.js {

          parse_ok, xls_hash = xls_to_hash tmp_file, file_ext

          if parse_ok
            render json: xls_hash
          else
            render json: false
          end

      }
    end

    File.delete(tmp_file)
  end

  def show

    file_ext = BmXlsParser.get_file_extension(Attachment.find(params[:id]).diskfile)
    respond_to do |format|
      format.js {
        parse_ok, xls_hash = xls_to_hash(Attachment.find(params[:id]).diskfile, file_ext)
        render json: xls_hash
      }
    end
  end


  protected

  def xls_to_hash(file_path, file_extension)
    begin

      if(file_extension == "xls")
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xls)
      end

      if(file_extension == "xlsx")
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xlsx)
      end

      if(file_extension == "")
        return false, nil
      end

      razao_social    = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["razaosocial_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["razaosocial_field_column"].to_i)

      cnpj            = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["cnpj_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["cnpj_field_column"].to_i)

      # Faço o CNPJ virar somente número
      cnpj = cnpj.to_s
      cnpj.gsub! '.', ''
      cnpj.gsub! '/', ''
      cnpj.gsub! '-', ''

      numerofornsap   = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["numerofornsap_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["numerofornsap_field_column"].to_i)

      emailiberacao   = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["emailliberacao_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["emailliberacao_field_column"].to_i)

      numerocontrato  = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["numerocontrato_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["numerocontrato_field_column"].to_i)

      empresacontrat  = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["empresacontratante_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["empresacontratante_field_column"].to_i)

      numempresacont  = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["numeroempresacont_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["numeroempresacont_field_column"].to_i)

      vigencia        = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["vigencia_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["vigencia_field_column"].to_i)

      npedidoitem     = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["npedidoenitem_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["npedidoenitem_field_column"].to_i)

      nomeaprov       = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["nomeaprovador_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["nomeaprovador_field_column"].to_i)

      numeroaprov     = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["numeroaprovador_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["numeroaprovador_field_column"].to_i)

      localprestacao  = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["localprestacao_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["localprestacao_field_column"].to_i)

      periodoref      = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["periodoreferencia_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["periodoreferencia_field_column"].to_i)

      descservico     = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["descricaoservico_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["descricaoservico_field_column"].to_i)

      valor           = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["valor_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["valor_field_column"].to_i)

      begin
        moeda = spreadsheet.excelx_format(Setting.plugin_bm_xls_to_form["moeda_field_row"].to_i, Setting.plugin_bm_xls_to_form["moeda_field_column"].to_i)
        if moeda.include? "R$"
          moeda = "R$"
        else
          moeda = /^.*?\[\$(.+?)-/.match(moeda).captures[0]
        end
      rescue
        moeda = ""
      end

      valor           = spreadsheet.cell(
          Setting.plugin_bm_xls_to_form["valor_field_row"].to_i,
          Setting.plugin_bm_xls_to_form["valor_field_column"].to_i)

      valor = valor.round(2)
      valor = sprintf('%.2f', valor)
      valor.gsub! '.', ','

      linha_ct   = Setting.plugin_bm_xls_to_form["row_linhasct"].to_i
      coluna_ct  = Setting.plugin_bm_xls_to_form["column_linhasct"].to_i
      coluna_ct_fim = Setting.plugin_bm_xls_to_form["column_final_linhasct"].to_i

      linhas_do_contrato = []

      valor_soma = 0.0

      #Leio todas as linhas do contrato enquanto o item "Nº da Linha do CT no SAP" for não nulo
      begin

        linha_ct_vazia = false

        linha_atual = []
        #Leio a linha atual do contrato
        for i in coluna_ct..coluna_ct_fim
          item = spreadsheet.cell(linha_ct, i)
          linha_atual.push(item)
        end

        #Verifico se os campos obrigatórios estão preenchidos
        #Se não estiverem, a linha não é adicionada
        #Só verifico a quantidade executada
        #No redmine, verificam-se as colunas B até J para preenchimento obrigatório
        if linha_atual[4].present? and linha_atual[4] > 0

            qtd_executada = linha_atual[4]
            qtd_executada = convert_to_float_str(qtd_executada)
            linha_atual[4] = qtd_executada

            preco_unitario = linha_atual[5]
            preco_unitario = convert_to_float_str(preco_unitario)
            linha_atual[5] = preco_unitario

            total = linha_atual[6]
            valor_soma += total
            total = convert_to_float_str(total)
            linha_atual[6] = total

            linhas_do_contrato.push(linha_atual)

        end

        #Verifico se o item "Nº da Linha do CT no SAP" esta vazio
        if(linha_atual[0]==nil)
          linha_ct_vazia = true
        end

        linha_ct = linha_ct+1

      end while linha_ct_vazia == false

    rescue
      return false, nil
    end

    valor_soma = valor_soma.round(2)
    valor_soma = sprintf('%.2f', valor_soma)
    valor_soma.gsub! '.', ','

    if (valor_soma != valor)
      Rails.logger.info(l(:bm_value_mismatch))
    end

    bmobj =
    {
      Setting.plugin_bm_xls_to_form["razaosocial_field"].to_i         => razao_social,
      Setting.plugin_bm_xls_to_form["cnpj_field"].to_i                => cnpj,
      Setting.plugin_bm_xls_to_form["numerofornsap_field"].to_i       => numerofornsap,
      Setting.plugin_bm_xls_to_form["numerocontrato_field"].to_i      => numerocontrato,
      Setting.plugin_bm_xls_to_form["emailliberacao_field"].to_i      => emailiberacao,
      Setting.plugin_bm_xls_to_form["empresacontratante_field"].to_i  => empresacontrat,
      Setting.plugin_bm_xls_to_form["numeroempresacont_field"].to_i   => numempresacont,
      Setting.plugin_bm_xls_to_form["vigencia_field"].to_i            => vigencia,
      Setting.plugin_bm_xls_to_form["npedidoenitem_field"].to_i       => npedidoitem,
      Setting.plugin_bm_xls_to_form["nomeaprovador_field"].to_i       => nomeaprov,
      Setting.plugin_bm_xls_to_form["numeroaprovador_field"].to_i     => numeroaprov,
      Setting.plugin_bm_xls_to_form["localprestacao_field"].to_i      => localprestacao,
      Setting.plugin_bm_xls_to_form["periodoreferencia_field"].to_i   => periodoref,
      Setting.plugin_bm_xls_to_form["descricaoservico_field"].to_i    => descservico,
      Setting.plugin_bm_xls_to_form["valor_field"].to_i               => valor,
      Setting.plugin_bm_xls_to_form["moeda_field"].to_i               => moeda,


      Setting.plugin_bm_xls_to_form["grid_field"].to_i                => linhas_do_contrato
    }

    return true, bmobj
  end

  def format_number(locale, value)
    if value
      number_with_precision value, locale: locale, precision: 2
    end
  end

  def convert_to_float_str(value)
    fmt = value
    fmt.round(3)
    fmt = sprintf('%.3f', fmt)
    fmt.gsub! '.', ','
  end

end
