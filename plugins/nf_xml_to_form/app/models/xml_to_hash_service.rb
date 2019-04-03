class XmlToHashService
  class << self
    include ActionView::Helpers::NumberHelper

    def convert(xml, tracker_id)
      locale = User.current.language.blank? ? I18n.locale : User.current.language

      xml = Nokogiri::XML(xml).remove_namespaces!

      optante_simples = xml.xpath('//InfNfse/OptanteSimplesNacional').text
      if optante_simples.strip.downcase =~ /^s(im)?$/
        optante_simples = '1'
      elsif I18n.transliterate(optante_simples).strip.downcase =~ /^n(a?o)?$|^0$/
        optante_simples = '2'
      end

      aliquota = format_number_separator xml.xpath('//Servico//Aliquota').text

      if aliquota.present? and optante_simples == '1' and aliquota.to_f == 0
        aliquota = '5.0'
      end

      unless aliquota.blank?
        aliquota = aliquota.tr(',', '.').to_f
        aliquota = aliquota >= 1 ? aliquota : aliquota * 100
      end

      valor_iss = ["//ValorIss", "//ValorIssRetido"].map do |s|
        v = xml.xpath(s).text
        format_number_separator(v).to_f if v.present?
      end.compact.max

      valor_servico = format_number_separator xml.xpath('//Servico//ValorServicos').text
      base_reduzida = false

      if valor_iss.present? && aliquota.present? && valor_servico.present?
        valor_servico = valor_servico.to_f
        if aliquota != 0 && valor_iss != 0
          base_iss = valor_iss * 100 / aliquota
          base_reduzida = !(base_iss.in? (valor_servico - 1 .. valor_servico + 1))
        end
      end

      iss_retido = xml.xpath('//Servico//IssRetido').text

      if base_reduzida || iss_retido.strip.downcase =~ /^(s(im)?|true|retido)$/
        iss_retido = '1'
      elsif I18n.transliterate(iss_retido).strip.downcase =~ /^(n(a?o)?|false)$/
        iss_retido = '2'
      end

      aliquota_icms = xml.xpath('//Servico//AliquotaICMS').text

      unless aliquota_icms.blank?
        aliquota_icms = aliquota_icms.to_f
        aliquota_icms = aliquota_icms >= 1 ? aliquota_icms : aliquota_icms * 100
      end

      prestador_municipio = xml.xpath('//PrestadorServico//CodigoMunicipio').text
      prestador_municipio = nil if prestador_municipio.to_i.zero?

      orgao_gerador = xml.xpath('//OrgaoGerador//CodigoMunicipio').text
      orgao_gerador = orgao_gerador.to_i.zero? ? prestador_municipio : orgao_gerador

      orgao_gerador_uf = xml.xpath('//OrgaoGerador//Uf').text
      orgao_gerador_uf = orgao_gerador_uf.blank? ? xml.xpath('//PrestadorServico//Uf').text : orgao_gerador_uf

      prestacao_municipio = xml.xpath('//Servico//CodigoMunicipio').text
      prestacao_municipio = nil if prestacao_municipio.to_i.zero?

      numero_nota = xml.xpath('//InfNfse/Numero').text.last(9)

      unless Setting.plugin_nf_xml_to_form['complete_with_zeroes'].blank?
        if tracker_id.in?(Setting.plugin_nf_xml_to_form['complete_with_zeroes'])
          numero_nota = numero_nota.rjust(9,'0') unless numero_nota.blank?
        end
      end

      hora_emissao = xml.xpath('//InfNfse/DataEmissao').text
      if hora_emissao.present?
        hora_emissao = Time.parse(hora_emissao).strftime('%H:%M:%S')
      end

      valor_liquido = format_number_separator xml.xpath('//Servico//ValorLiquidoNfse').text
      if tracker_id.in? Setting.plugin_nf_xml_to_form['transport_converter_issues']
        valor_liquido = valor_servico - valor_iss
      end

      {
        Setting.plugin_nf_xml_to_form['numero_field'].to_i                             => numero_nota.rjust(9,'0'),
        Setting.plugin_nf_xml_to_form['codigo_verificacao_field'].to_i                 => xml.xpath('//InfNfse/CodigoVerificacao').text,
        Setting.plugin_nf_xml_to_form['data_emissao_field'].to_i                       => (Date.parse(xml.xpath('//InfNfse/DataEmissao').text).to_date rescue ''),
        Setting.plugin_nf_xml_to_form['natureza_operacao_field'].to_i                  => xml.xpath('//InfNfse/NaturezaOperacao').text,
        Setting.plugin_nf_xml_to_form['optante_simples_nacional_field'].to_i           => optante_simples,
        Setting.plugin_nf_xml_to_form['servico_valores_valor_servicos_field'].to_i     => format_number(locale, valor_servico),
        Setting.plugin_nf_xml_to_form['servico_valores_iss_retido_field'].to_i         => iss_retido,
        Setting.plugin_nf_xml_to_form['servico_valores_valor_base_calculo_iss_field'].to_i => format_number(locale, xml.xpath('//Servico//BaseCalculo').text),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_aliquota_iss_field'].to_i => format_number(locale, aliquota),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_liquido_nfse_field'].to_i => format_number(locale, valor_liquido),
        Setting.plugin_nf_xml_to_form['servico_item_lista_servico_field'].to_i         => xml.xpath('//Servico//ItemListaServico').text,
        Setting.plugin_nf_xml_to_form['servico_codigo_tributacao_municipio'].to_i      => xml.xpath('//Servico//CodigoTributacaoMunicipio').text,
        Setting.plugin_nf_xml_to_form['servico_codigo_municipio'].to_i                 => prestacao_municipio,
        Setting.plugin_nf_xml_to_form['construcao_civil_codigo_obra'].to_i             => xml.xpath('//ConstrucaoCivil//CodigoObra').text,
        Setting.plugin_nf_xml_to_form['servico_uf'].to_i                               => xml.xpath('//Servico//Uf').text,
        Setting.plugin_nf_xml_to_form['prestador_cnpj'].to_i                           => xml.xpath('//PrestadorServico//Cnpj').text.gsub(/\D/, ''),
        Setting.plugin_nf_xml_to_form['prestador_inscricao_municipal'].to_i            => xml.xpath('//PrestadorServico//InscricaoMunicipal').text,
        Setting.plugin_nf_xml_to_form['prestador_razao_social'].to_i                   => xml.xpath('//PrestadorServico//RazaoSocial').text,
        Setting.plugin_nf_xml_to_form['prestador_codigo_municipio'].to_i               => prestador_municipio,
        Setting.plugin_nf_xml_to_form['prestador_uf'].to_i                             => xml.xpath('//PrestadorServico//Uf').text,
        Setting.plugin_nf_xml_to_form['tomador_cnpj'].to_i                             => xml.xpath('//TomadorServico//Cnpj').text.gsub(/\D/, ''),
        Setting.plugin_nf_xml_to_form['orgao_gerador_codigo_municipio'].to_i           => orgao_gerador,
        Setting.plugin_nf_xml_to_form['orgao_gerador_uf'].to_i                         => orgao_gerador_uf,
        Setting.plugin_nf_xml_to_form['pedido'].to_i                                   => xml.xpath('//Pedido//Pedido').text,
        Setting.plugin_nf_xml_to_form['contrato'].to_i                                 => xml.xpath('//Pedido//Contrato').text,
        Setting.plugin_nf_xml_to_form['frs'].to_i                                      => xml.xpath('//Pedido//FRS').text,
        Setting.plugin_nf_xml_to_form['rf'].to_i                                       => xml.xpath('//Pedido//RF').text,
        Setting.plugin_nf_xml_to_form['servico_valores_valor_valor_pis'].to_i          => format_number(locale, xml.xpath('//Servico//Valores//ValorPis').text),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_valor_cofins'].to_i       => format_number(locale, xml.xpath('//Servico//Valores//ValorCofins').text),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_valor_ir'].to_i           => format_number(locale, xml.xpath('//Servico//Valores//ValorIr').text),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_valor_csll'].to_i         => format_number(locale, xml.xpath('//Servico//Valores//ValorCsll').text),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_valor_iss'].to_i          => format_number(locale, valor_iss),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_valor_inss'].to_i         => format_number(locale, xml.xpath('//Servico//Valores//ValorInss').text),
        Setting.plugin_nf_xml_to_form['asn'].to_i                                      => xml.xpath('//Pedido//ASN').text,
        Setting.plugin_nf_xml_to_form['coleta_int'].to_i                               => xml.xpath('//Pedido//ColetaINT').text,
        Setting.plugin_nf_xml_to_form['servico_valores_valor_valor_deducoes'].to_i     => format_number(locale, xml.xpath('//Servico//Valores//ValorDeducoes').text),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_outros_descontos'].to_i   => format_number(locale, xml.xpath('//Servico//Valores//OutrosDescontos').text),
        Setting.plugin_nf_xml_to_form['servico_quantidade'].to_i                       => xml.xpath('//Servico//Quantidade').text,
        Setting.plugin_nf_xml_to_form['servico_unidade'].to_i                          => xml.xpath('//Servico//Unidade').text,
        Setting.plugin_nf_xml_to_form['servico_valor_desconto'].to_i                   => format_number(locale, xml.xpath('//Servico//ValorDesconto').text),
        Setting.plugin_nf_xml_to_form['servico_valor_issqn'].to_i                      => format_number(locale, xml.xpath('//Servico//ValorIssqn').text),
        Setting.plugin_nf_xml_to_form['prestador_regime_especial_tributacao'].to_i     => xml.xpath('//PrestadorServico//RegimeEspecialTributacao').text,
        Setting.plugin_nf_xml_to_form['prestador_municipio'].to_i                      => xml.xpath('//PrestadorServico//Endereco//Municipio').text,
        Setting.plugin_nf_xml_to_form['tomador_nome_fantasia'].to_i                    => xml.xpath('//TomadorServico//NomeFantasia').text,
        Setting.plugin_nf_xml_to_form['prestador_regime_especial_tributacao'].to_i     => xml.xpath('//PrestadorServico//RegimeEspecialTributacao').text,
        Setting.plugin_nf_xml_to_form['tomador_municipio'].to_i                        => xml.xpath('//TomadorServico//Endereco//Municipio').text,
        Setting.plugin_nf_xml_to_form['local_prestacao'].to_i                          => xml.xpath('//InfNfse/LocalPrestacao').text,
        Setting.plugin_nf_xml_to_form['pedido_discriminacao'].to_i                     => xml.xpath('//Pedido//Discriminacao').text,
        Setting.plugin_nf_xml_to_form['numero_rps'].to_i                               => xml.xpath('//IdentificacaoRps//Numero').text,
        Setting.plugin_nf_xml_to_form['serie_rps'].to_i                                => xml.xpath('//IdentificacaoRps//Serie').text,
        Setting.plugin_nf_xml_to_form['tipo_rps'].to_i                                 => xml.xpath('//IdentificacaoRps//Tipo').text,
        Setting.plugin_nf_xml_to_form['data_emissao_rps'].to_i                         => (Date.parse(xml.xpath('//InfNfse//DataEmissaoRps').text).to_date rescue ''),
        Setting.plugin_nf_xml_to_form['incentivador_cultural'].to_i                    => xml.xpath('//InfNfse//IncentivadorCultural').text,
        Setting.plugin_nf_xml_to_form['cep_prestador'].to_i                            => xml.xpath('//PrestadorServico//Endereco//Cep').text,
        Setting.plugin_nf_xml_to_form['cep_tomador'].to_i                              => xml.xpath('//TomadorServico//Endereco//Cep').text,
        Setting.plugin_nf_xml_to_form['email_prestador'].to_i                          => xml.xpath('//PrestadorServico//Contato//Email').text,
        Setting.plugin_nf_xml_to_form['telefone_prestador'].to_i                       => xml.xpath('//PrestadorServico//Contato//Telefone').text,
        Setting.plugin_nf_xml_to_form['endereco'].to_i                                 => xml.xpath('//PrestadorServico//Endereco//Endereco').text + ' ' + xml.xpath('//PrestadorServico//Endereco//Numero').text,
        Setting.plugin_nf_xml_to_form['servico_valores_valor_valor_icms'].to_i         => format_number(locale, xml.xpath('//Servico//Valores//ValorICMS').text),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_base_calculo_icms_field'].to_i => format_number(locale, xml.xpath('//Servico//Valores//BaseCalculoICMS').text),
        Setting.plugin_nf_xml_to_form['servico_valores_valor_aliquota_icms_field'].to_i     => format_number(locale, aliquota_icms),
        Setting.plugin_nf_xml_to_form['chave_acesso_cte'].to_i                         => xml.xpath('//InfNfse/ChaveAcesso').text,
        Setting.plugin_nf_xml_to_form['inicio_prestacao'].to_i                         => xml.xpath('//Servico//InicioPrestaco').text,
        Setting.plugin_nf_xml_to_form['termino_prestacao'].to_i                        => xml.xpath('//Servico//TerminoPrestacao').text,
        Setting.plugin_nf_xml_to_form['prestador_inscricao_estadual'].to_i             => xml.xpath('//PrestadorServico//InscricaoEstadual').text,
        Setting.plugin_nf_xml_to_form['hora_emissao'].to_i                             => hora_emissao,
        Setting.plugin_nf_xml_to_form['numero_protocolo'].to_i                         => xml.xpath('//InfNfse//NumeroProtocolo').text
      }
    end

    def format_number_separator(value)
      return value unless value.is_a? String
      value.gsub(/\.(?=.*,)/, '').gsub(/,(?=.*\.)/, '').tr(',', '.')
    end

    def format_number(locale, value)
      number_with_precision(value, locale: locale, precision: 2) if value
    end
  end
end
