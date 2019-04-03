require 'csv'
require "i18n"

module MaterialXmlConverter
  XPATH_MUNICIPIO_GERADOR =  ['//OrgaoGerador/CodigoMunicipio', '//orgao_gerador/codigo_municipio', '//TimbrePrefeituraLinha1', '//prestador/municipio', '//enderEmit/cMun','//DadosPrestador/Endereco/CodigoMunicipio', '//DadosPrestador/Endereco/Municipio', '//NOTA/ORGAO_GERADOR_ES_MUNICIPIO', '//NOTA/ES_MUNICIPIO', '//tsMunPtd', '/nfse/codigoMunicipio']
  XPATH_VALOR_SERVICO     =  ['//totais/valotTotalNota', '//Servico/Valores/ValorServicos', '//Valores/ValorServicos', '//valorTotal', '//ValorTotalNota', '//valor_servico', '//total//vNF', '//VlrTotal', '//Field[@Name="ForValorTotalServicos1"]/Value', '//NOTA/VL_SERVICO', '//tsVlrSvc', '//Valores/ValorNota']

  XPATH_ISS_RETIDO        =  ['//Valores/ValorISS','//NOTA_FISCAL/ISSQNTotal', '//totais/valorTotalISS', '//ImpostosRetidos/VlrIssRetido'  , '//NOTA/VL_ISS_RETIDO', '//ISSQNCliente', '//valor_iss_retido', '//Iss/Vlr', '//Field[@Name="forValorISSRetido1"]/Value', '//ValorIssRetido']

  XPATH_DISCRIMINACAO     =  ['//Discriminacao', '//nf-e/obs', '//Observacao', '//discriminacao', '//infAdic/infAdFisco', '//DescricaoTipoServico', '//ITENS/Servico', '//NOTA/DISCRIMINACAO', '//descricaoNota','//tsObsNfe', '//tsDesSvc', '//tsDesItem', '//Servicos/Descricao']
  XPATH_CODIGO_MUNICIPIO_PRESTACAO = ['//Servico/CodigoMunicipio', '//DeclaracaoPrestacaoServico/CodigoMunicipio', '//municipioIncidencia', '//MunicipioPrestacaoServico', '//municipio_prestacao_servico', '//ide/cMunFG', '//servicoCidade', '//LocalPrestacao', ['//NOTA/OUTRAS_INFORMACOES', /^município de prestação: (.*)$/i], '//localPrestacao/descricaoMunicipio', '//tcInfNFE/tsMunSvc']

  XPATH_MUNICIPIO_PRESTADOR = ['//DadosPrestador/Endereco/CodigoMunicipio','//PrestadorServico/Endereco/CodigoMunicipio', '//prestacao_servico//codigo_municipio', '//prestador/municipio', '//enderEmit/cMun', '//DadosPrestador/Endereco/Municipio', '//NOTA/PRE_ENDERECO_ES_MUNICIPIO', '//prestador/endereco/descricaoMunicipio', '//tsMunPtd', '//PrestadorServico/Endereco/Cidade']

  UF = {
    "11" => "RO",
    "12" => "AC",
    "13" => "AM",
    "14" => "RR",
    "15" => "PA",
    "16" => "AP",
    "17" => "TO",
    "21" => "MA",
    "22" => "PI",
    "23" => "CE",
    "24" => "RN",
    "25" => "PB",
    "26" => "PE",
    "27" => "AL",
    "28" => "SE",
    "29" => "BA",
    "31" => "MG",
    "32" => "ES",
    "33" => "RJ",
    "35" => "SP",
    "41" => "PR",
    "42" => "SC",
    "43" => "RS",
    "50" => "MS",
    "51" => "MT",
    "52" => "GO",
    "53" => "DF"
  }


  def self.convert(xml)
    ret = '<?xml version="1.0" encoding="UTF-8"?>'
    ret << build_CompNfse(Nokogiri::XML(xml).remove_namespaces!)
    ret
  end

  def self.build_CompNfse(xml)
    ret = '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="3.10">'
    ret << build_protNFe(xml)
    ret << '</nfeProc>'
    ret
  end

  def self.build_protNFe(xml)
    ret = '<protNFe versao="3.10">'
    ret << build_infProt(xml)
    ret << '</protNFe>'
    ret
  end

  def self.build_infProt(xml)
    ret = '<infProt>'
    ret << build_infProt_chNFe(xml)
    ret << '</infProt>'

    ret
  end

  def self.build_infProt_chNFe(xml)
    build_tag('ChaveAcesso',xml, '//chNFe')
  end

  def self.build_tag(tag, xml, *xpaths)
    if tag_value = value(xml, *xpaths)
      "<#{tag}>#{tag_value}</#{tag}>"
    else
      "<#{tag} />"
    end
  end

  def self.build_tag_numero_nfse(xml, *xpaths)
    if tag_value = value(xml, *xpaths)
      "<Numero>#{tag_value.gsub(/[^\d]/, '')}</Numero>"
    else
      "<Numero />"
    end
  end

  def self.value(xml, *xpaths)
    xpaths.each do |xpath|
      if xpath.is_a? String
        if (result = xml.xpath(xpath).first
                                     .try(:text)
                                     .try(:encode, 'UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
                                     .try(:gsub, /R\$/i, '')
                                     .try(:scrub)) && !result.blank?
          return result
        end
      else
        if xpath.is_a? Array
          match = xml.xpath(xpath[0]).first
                                     .try(:text)
                                     .try(:encode, 'UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
                                     .try(:gsub, /R\$/i, '')
                                     .try(:scrub)
                                     .try(:gsub, /\s+/, " ")
                                     .try(:match, xpath[1])
        else
          match = xml.text
                     .encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
                     .scrub
                     .gsub(/\s+/, " ")
                     .match(xpath)
        end

        if match && (result = match[1]) && !result.blank?
          return result
        end
      end
    end
    nil
  end
end
