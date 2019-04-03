module PacPdfHelper
  # include ActionView::Helpers::NumberHelper
  # Returns a PDF string of a single issue
  #def issue_to_pdf_with_hidden_with_pac(issue, assoc={})
  def self.issue_pac_pdf(issue, assoc={})
    i = 1
    str = "<html lang='pt-BR' dir='ltr'>"
    str += "<head>"
    str += "<meta charset='utf-8'>"
    str += "<style>"
    str += "div.content {page-break-inside: avoid;}"
    # str += "table {border-collapse: collapse;}"
    # # str += "table, th, td {border: 1px solid black;}"
    str += "</style>"
    str += "</head>"
    str += "<body>"
    str += "<div style='margin-bottom: 15px'>"
    str += "<div style='float: left; width:50%; margin-bottom: 30px;'>"
    str += "<img src='"+Rails.root.to_s+"/public/themes/vale/images/logo_login.gif'>"
    # str += "<img src='/home/romulo-brito/Projetos/servicecenter/public/themes/vale/images/logo_login.gif'>"
    # str += image_tag("images/logo_login.gif", :alt => "logo Vale")
    str += "</div>"
    str += "<div style='float: right; width:50%; text-align:right'>"
    str += "<span><strong>CONSULTORIA GERAL</strong></span><br>"
    str += "<span><strong>PAC - PEDIDO DE AUTORIZAÇÃO PARA CONTRATAÇÃO</strong></span><br>"
    str += "</div>"
    str += "</div>"
    str += "<br style='clear:both;'/>"
    str += "<div style='border: 1px solid black;'>"
    str += "<div class='content' style='float: left; width:50%;'>"
    str += "<span><strong>"+I18n.t('pdf_helrper.departamento')+":</strong></span> "+issue.custom_field_value(Setting.plugin_pac_consultoria_geral["campo_area"])+"<br>"
    str += "<span><strong>GERÊNCIA:</strong></span> "+User.find(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["gestor_contrato"])).name+"<br>"
    str += "<span><strong>SOLICITANTE DO PAC:</strong></span> "+issue.author.name+"<br>"
    str += "<br>"
    str += "<div class='content' style='border-top:1px solid black;>'"
    str += "<span><strong>FORNECEDOR - RAZÃO SOCIAL:</strong></span><br>"+issue.custom_field_value(Setting.plugin_pac_consultoria_geral["razao_social"])+"<br>"
    str += "<span><strong>CNPJ DO CONTRATO:</strong></span><br>"+issue.custom_field_value(Setting.plugin_pac_consultoria_geral["cnpj_contrato"])+"<br>"
    str += "<span><strong>CNPJ QUE VAI EMITIR A FATURA:</strong></span><br>"+issue.custom_field_value(Setting.plugin_pac_consultoria_geral["cnpj_emissor"])+"<br>"
    str += "<span><strong>FORNECEDOR CERTIFICADO?</strong>"
    str += "&nbspSIM" if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["fornecedor_certificado"]).to_i == 1
    str += "&nbspNÃO" unless issue.custom_field_value(Setting.plugin_pac_consultoria_geral["fornecedor_certificado"]).to_i == 1
    str += "</span><br><br>"
    str += "</div>"
    str += "</div>"
    str += "<div class='content' style='width:49%; float: right; border-left: 1px solid black; padding: 0 0 3px 3px;'>"
    str += "<span><strong>["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Novo Contrato")
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] NOVO CONTRATO</strong></span><br>"
    str += "<span><strong> ["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["contrato_guardachuva"]).to_i == 1
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] CONTRATO GUARDACHUVA</strong></span><br>"
    str += "<span><strong> ["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["metodo_contratacao"]).include?("Direta")
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] DIRETA</strong></span><br>"
    str += "<span><strong> ["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["metodo_contratacao"]).include?("Regularização")
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] REGULARIZAÇÃO</strong></span><br>"
    str += "<span><strong> ["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["metodo_contratacao"]).include?("Concorrencial")
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] CONCORRENCIAL</strong></span><br>"
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["metodo_contratacao"]).include?("Concorrencial")
      str += "Selecionado o de menor valor ? &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp <span><strong> SIM&nbsp["
      if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["selecionado_menor_valor"]).to_i == 1
        str += "X"
      else
        str += "&nbsp&nbsp"
      end
      str += "]&nbsp&nbsp&nbsp&nbsp NÃO&nbsp["
      unless issue.custom_field_value(Setting.plugin_pac_consultoria_geral["selecionado_menor_valor"]).to_i == 1
        str += "X"
      else
        str += "&nbsp&nbsp"
      end
      str += "] </strong></span>"
    end
    str += "<br>"
    str += "<span><strong> ["
    unless issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Novo Contrato")
      str += "X"
    else
      str += "&nbsp"
    end
    str += "] ADITIVO</strong></span><br>"
    str += "<span><strong>&nbsp&nbsp&nbsp ["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Aditivo - Acréscimo de Saldo")
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] ACRÉSCIMO DE SALDO</strong></span><br>"
    str += "<span><strong>&nbsp&nbsp&nbsp ["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Aditivo - Acréscimo de Prazo")
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] ACRÉSCIMO DE PRAZO</strong></span><br>"
    str += "<span><strong> &nbsp&nbsp&nbsp ["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Aditivo - Alteração de Escopo")
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] ALTERAÇÃO DE ESCOPO</strong></span><br><br>"
    str += "<span><strong>["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Cessão de Contrato")
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "] CESSÃO DE CONTRATO</strong></span><br>"
    str += "<br><br>"

    str += "</div>"
    str += "<br style='clear:both;'/>"

    str += "<div class='content' style='border-top:1px solid black;>'"
    str += "<span><strong>#{i.to_s}.OBJETO:</strong></span><br>"
    i = i + 1
    str += issue.custom_field_value(Setting.plugin_pac_consultoria_geral["campo_objeto"])+"<br><br>"
    str += "</div>"

    str += "<div class='content' style='border-top:1px solid black;>'"
    str += "<span><strong>#{i.to_s}.JUSTIFICATIVA DA NECESSIDADE:</strong></span><br>"
    i = i + 1
    str += issue.custom_field_value(Setting.plugin_pac_consultoria_geral["justificativa_necessidade"])+"<br><br>"
    str += "</div>"

    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["justificativa_direta"]) != ""
      str += "<div class='content' style='border-top:1px solid black;>'"
      str += "<span><strong>#{i.to_s}.JUSTIFICATIVA PARA CONTRATAÇÃO DIRETA:</strong></span><br>"
      i = i + 1
      str += issue.custom_field_value(Setting.plugin_pac_consultoria_geral["justificativa_direta"])+"<br><br>"
      str += "</div>"
    end

    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["justificativa_regularicazao"]) != ""
      str += "<div class='content' style='border-top:1px solid black;>'"
      str += "<span><strong>#{i.to_s}.JUSTIFICATIVA PARA REGULARIZAÇÃO:</strong></span><br>"
      i = i + 1
      str += issue.custom_field_value(Setting.plugin_pac_consultoria_geral["justificativa_regularicazao"])+"<br><br>"
      str += "</div>"
    end

    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["justificativa_menor_valor"]) != ""
      str += "<div class='content' style='border-top:1px solid black;>'"
      str += "<span><strong>#{i.to_s}.JUSTIFICATIVA NÃO SELECIONADO DE MENOR VALOR:</strong></span><br>"
      i = i + 1
      str += issue.custom_field_value(Setting.plugin_pac_consultoria_geral["justificativa_menor_valor"])+"<br><br>"
      str += "</div>"
    end

    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["metodo_contratacao"]).include?("Concorrencial")
      str += "<div style='border-top:1px solid black;>'"
      str += "<span><strong>#{i.to_s}. CONTRATAÇÃO CONCORRENCIAL</span></strong>"
      i = i + 1
      str += "<table border='1'>"
      # str += "<table>"
      str += "<thead>"
      str += "<tr>"
      str += "<td><strong>Fornecedor</strong></td>"
      str += "<td><strong>Proposta Inicial</strong></td>"
      str += "<td><strong>Proposta Final</strong></td>"
      str += "<td><strong>Variação da Proposta (%)</strong></td>"
      str += "<td><strong>Diferença sobre o orçamento Vale (%)</strong></td>"
      str += "<td><strong>Declinou da concorrência?</strong></td>"
      str += "<td><strong>Desclassificado?</strong></td>"
      str += "</tr>"
      str += "</thead>"
      str += "<tbody>"
      concorrentes = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["grid_concorrentes"])
      if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["metodo_contratacao"]).include?("Concorrencial")
        json_concorrentes = JSON.parse(concorrentes.gsub("=>",":"))
        json_concorrentes.map { |k, v|
          str += "<tr>"
          str += "<td>"+v[Setting.plugin_pac_consultoria_geral["campo_nome_fornecedor"].to_s].to_s+"</td>"
          # binding.pry
          proposta_inicial = ActionController::Base.helpers.number_to_currency(v[Setting.plugin_pac_consultoria_geral["proposta_inicial"].to_s], unit: "", separator: ",", delimiter: ".")
          str += "<td>"+proposta_inicial+"</td>"
          # str += "<td>"+v[1616.to_s].to_s.gsub(".",",")+"</td>"
          proposta_final = ActionController::Base.helpers.number_to_currency(v[Setting.plugin_pac_consultoria_geral["proposta_final"].to_s], unit: "", separator: ",", delimiter: ".")
          str += "<td>"+proposta_final+"</td>"
          # str += "<td>"+v[1624.to_s].to_s.gsub(".",",")+"</td>"
          str += "<td>"+v[Setting.plugin_pac_consultoria_geral["variacao_proposta"].to_s].to_s.gsub(".",",")+"</td>"
          str += "<td>"+v[Setting.plugin_pac_consultoria_geral["diferenca_orcamento"].to_s].to_s.gsub(".",",")+"</td>"
          str += "<td>"
          if v[Setting.plugin_pac_consultoria_geral["declinou"].to_s].to_i == 1
            str += "Sim"
          else
            str += "Não"
          end
          str += "</td>"
          str += "<td>"
          if v[Setting.plugin_pac_consultoria_geral["desclassificado"].to_s].to_i == 1
            str += "Sim"
          else
            str += "Não"
          end
          str += "</td>"
        }
      end
      str += "</tbody>"
      str += "</table>"
      str += "<br><br>"
      str += "<span><strong>#{i.to_s}. CRITÉRIOS DE SELEÇÃO</span></strong><br>"
      i = i + 1
      issue.custom_field_value(Setting.plugin_pac_consultoria_geral["criterios_selecao"]).each {|criterio|
        str += criterio.to_s + "&nbsp"
      }
      str += issue.custom_field_value(Setting.plugin_pac_consultoria_geral["outros_metodos"]).to_s
      str += "</div>"
    end

    str += "<br>"

    str += "<div style='border-top:1px solid black;>'"
    str += "<span><strong>#{i.to_s}. EMPRESAS DO GRUPO</span></strong><br>"
    str += "<div style='padding-left: 10px'><span><strong>#{i.to_s}.1 O SERVIÇO PODERÁ SER PRESTADO PARA AS EMPRESAS DO GRUPO?</span></strong> &nbsp&nbsp&nbsp SIM&nbsp["
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["prestrado_entre_grupo"]).to_i == 1
      str += "X"
    else
      str += "&nbsp&nbsp"
    end
    str += "]&nbsp&nbsp&nbsp&nbsp NÃO&nbsp["
    unless issue.custom_field_value(Setting.plugin_pac_consultoria_geral["prestrado_entre_grupo"]).to_i == 1
      str += "X]"
    else
      str += "&nbsp&nbsp]"
    end
    str += "</div>"
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["prestrado_entre_grupo"]).to_i == 1
      str += "<div style='padding-left: 10px'><span><strong>#{i.to_s}.2 DISTRIBUIÇÃO DE SALDO ENTRE EMPRESAS DO GRUPO</span></strong><br>"
      distribuicao = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["distribuicao"])
      str += "<table border='solid 1px black'>"
      # str += "<table>"
      str += "<thead>"
      str += "<tr>"
      str += "<td><strong>Empresa</strong></td>" #98
      str += "<td><strong>Valor Distribuído (%)</strong></td>" #1619
      str += "</tr>"
      str += "</thead>"
      str += "<tbody>"
      if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["prestrado_entre_grupo"]).to_i == 1
        json_distribuicao = JSON.parse(distribuicao.gsub("=>",":"))
        json_distribuicao.map { |k, v|
          str += "<tr>"
          str += "<td>"+v[Setting.plugin_pac_consultoria_geral["empresa_vale"].to_s].to_s+"</td>"
          str += "<td>"+v[Setting.plugin_pac_consultoria_geral["valor_distribuido"].to_s].to_s+"</td>"
          str += "</tr>"
        }
      end
      str += "</tbody>"
      str += "</table>"
      str += "</div>"
    end
    i = i + 1
    str += "</div>"

    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Novo Contrato") || issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Aditivo - Acréscimo de Saldo")
      str += "<br><div class='content' style='border-top:1px solid black;>'"
      str += "<span><strong>#{i.to_s}. VALORES ENVOLVIDOS</span></strong><br>"
      i = i + 1
      str += "<div style='padding-left: 3px; padding-right: 3px;'>"
      str += "<span><strong>Moeda: </span></strong>"
      str += issue.custom_field_value(Setting.plugin_pac_consultoria_geral["campo_moeda"]) + "<br>"
      str += "<table style='width: 60%;'>"
      str += "<tr>"
      str += "<td width='70%'><span><strong>Valor bruto do Serviço: </span></strong></td>"
      valor_bruto = ActionController::Base.helpers.number_to_currency(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["valor_bruto_servico"]), unit: "", separator: ",", delimiter: ".")
      str += "<td width='30%' align='right'>"+valor_bruto+"</td>"
      # str += "<br>"
      str += "</tr>"
      str += "<tr>"
      str += "<td><span><strong>Valor das Despesas: </span></strong></td>"
      # valor_despesas = "%.2f" % issue.custom_field_value(1601).to_f
      valor_despesas = ActionController::Base.helpers.number_to_currency(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["valor_despesas"]), unit: "", separator: ",", delimiter: ".")
      str += "<td align='right'>"+valor_despesas+"</td>"
      str += "</tr>"
      # str += "<br>"
      str += "<tr>"
      str += "<td><span><strong>TOTAL do PAC: </span></strong></td>"
      valor_total = ActionController::Base.helpers.number_to_currency(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["valor_total_pac"]), unit: "", separator: ",", delimiter: ".")
      str += "<td align='right'>"+valor_total+"</td>"
      str += "</tr>"
      # str += "<br>"
      unless issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Novo Contrato")
        str += "<tr>"
        str += "<td><span><strong>Valor ATUAL do Contrato: </span></strong></td>"
        valor_atual = ActionController::Base.helpers.number_to_currency(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["valor_atual_contrato"]), unit: "", separator: ",", delimiter: ".")
        str += "<td align='right'>"+valor_atual+"</td>"
        str += "</tr>"
        # str += "<br>"
        str += "<tr>"
        str += "<td><span><strong>Valor do contrato após aditivo (Atual + PAC): </span></strong></td>"
        valor_apos_aditivo = ActionController::Base.helpers.number_to_currency(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["valor_apos_aditivo"]), unit: "", separator: ",", delimiter: ".")
        str += "<td align='right'>"+valor_apos_aditivo+"</td>"
        str += "</tr>"
        # str += "<br>"
      end
      str += "</table>"
      str += "<br>"
      str += "</div>"
      str += "</div>"
    end

    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Novo Contrato") || issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Aditivo - Acréscimo de Prazo")
      str += "<div class='content' style='border-top:1px solid black;>'"
      str += "<span><strong>#{i.to_s}. PRAZO DE VIGÊNCIA</span></strong><br>"
      i = i + 1
      str += "<div style='padding-left: 3px;'>"
      str += "<table>"
      str += "<tr>"
      str += "<td><span><strong>Início do Contrato: </span></strong></td>"
      inicio_contrato = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["inicio_contrato"]).to_date
      if inicio_contrato.is_a? Date
        inicio_contrato_string = inicio_contrato.strftime("%d/%m/%Y")
        str += "<td>"+inicio_contrato_string+"</td>"
      end
      str += "</tr>"
      str += "<tr>"
      str += "<td><span><strong>Fim do Contrato: </span></strong></td>"
      fim_contrato = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["fim_contrato"]).to_date
      if fim_contrato.is_a? Date
        fim_contrato_string = fim_contrato.strftime("%d/%m/%Y")
        str += "<td>"+fim_contrato_string+"</td>"
      end
      str += "</tr>"
      if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Aditivo - Acréscimo de Prazo")
        str += "<tr>"
        str += "<td><span><strong>Fim do Contrato Atual: </span></strong></td>"
        fim_contrato = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["fim_contrato_atual"]).to_date
        if fim_contrato.is_a? Date
          fim_contrato_string = fim_contrato.strftime("%d/%m/%Y")
          str += "<td>"+fim_contrato_string+"</td>"
        end
        str += "</tr>"
      end
      str += "</table>"
      str += "<br>"
      str += "<br>"
      str += "</div>"
      str += "</div>"

      str += "<div class='content' style='border-top:1px solid black;>'"
      str += "<span><strong>#{i.to_s}. CONTENCIOSO</strong><small><i> (vigência de 10 anos)</small></i></span> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbspSIM["
      i = i + 1
      if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["contencioso"]).to_i == 1
        str += "X"
      else
        str += "&nbsp&nbsp"
      end
      str += "]&nbsp&nbsp&nbsp&nbsp NÃO&nbsp["
      unless issue.custom_field_value(Setting.plugin_pac_consultoria_geral["contencioso"]).to_i == 1
        str += "X]"
      else
        str += "&nbsp&nbsp]"
      end
      str += "<br><br></div>"
    end

    str += "<div class='content'  style='border-top:1px solid black;>'"
    str += "<div>"
    str += "<span><strong>#{i.to_s}. AUTORIZAÇÃO do GESTOR DO CONTRATO:&nbsp</strong></span>"+User.find(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["gestor_contrato"])).name
    i = i + 1
    str += "</div>"
    str += "<div style='width: 100%; text-align: right; padding-right: 15px; margin-bottom: 5px'>"
    str += "<br> Em "+PacConsultoriaGeral::Services::AprovacoesService.get_aprovacao(issue, Setting.plugin_pac_consultoria_geral["aprovacao_gestor"].to_i)
    str += "</div>"

    str += "<div class='content' style='border-top:1px solid black;>'"
    str += "<div>"
    str += "<span><strong>#{i.to_s}. AUTORIZAÇÃO DO GERENTE EXECUTIVO/DIRETOR:&nbsp</strong></span>"+User.find(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["gerente_diretor"])).name
    i = i + 1
    str += "</div>"
    str += "<div style='width: 100%; text-align: right; padding-right: 15px; margin-bottom: 5px'>"
    str += "<br> Em "+PacConsultoriaGeral::Services::AprovacoesService.get_aprovacao(issue, Setting.plugin_pac_consultoria_geral["aprovacao_gerente"].to_i)
    str += "</div>"

    str += "<div class='content' style='border-top:1px solid black;>'"
    str += "<div>"
    str += "<span><strong>#{i.to_s}. AUTORIZAÇÃO DO CONSULTOR GERAL:&nbsp</strong></span>"+User.find(issue.custom_field_value(Setting.plugin_pac_consultoria_geral["consultor_geral"])).name
    i = i + 1
    str += "</div>"
    str += "<div style='width: 100%; text-align: right; padding-right: 15px; margin-bottom: 5px'>"
    str += "<br> Em "+PacConsultoriaGeral::Services::AprovacoesService.get_aprovacao(issue, Setting.plugin_pac_consultoria_geral["aprovacao_consultor"].to_i)
    str += "</div>"

    str += "</div>"

    str += "<div style='text-align:right'><small><i><strong>É preciso rubricar todas as páginas deste documento.</small></i></strong></div>"


    pdf = WickedPdf.new.pdf_from_string(str)
    pdf
  end
end
