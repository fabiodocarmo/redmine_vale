require 'csv'
require "i18n"

module TransportXmlConverter
  XPATH_MUNICIPIO_GERADOR =  ['//OrgaoGerador/CodigoMunicipio', '//orgao_gerador/codigo_municipio', '//TimbrePrefeituraLinha1', '//prestador/municipio', '//enderEmit/cMun','//DadosPrestador/Endereco/CodigoMunicipio', '//DadosPrestador/Endereco/Municipio', '//NOTA/ORGAO_GERADOR_ES_MUNICIPIO', '//NOTA/ES_MUNICIPIO', '//tsMunPtd', '/nfse/codigoMunicipio', '//DadosTomador/Endereco/CodigoMunicipio']
  XPATH_VALOR_SERVICO     =  ['//totais/valotTotalNota', '//Servico/Valores/ValorServicos', '//Valores/ValorServicos', '//valorTotal', '//ValorTotalNota', '//valor_servico', '//total//vNF', '//VlrTotal', '//Field[@Name="ForValorTotalServicos1"]/Value', '//NOTA/VL_SERVICO', '//tsVlrSvc', '//Valores/ValorNota']

  XPATH_VALOR_ISS = ['//NOTA_FISCAL/ISSQNTotal', '//totais/valorTotalISS', '//ISSQNCliente', '//valor_iss', '//Iss/Vlr', '//Servico/Valores/ValorIss', '//Servico/valores/valorIss', '//VALOR_ISS', '//valorIss', '//tsVlrISSQN', '//valorISS', '//VlIssRet','//nf-e/valorImposto','//NfeValISsRetido','//vl_iss','//impostos/valor_iss','//itens/lista/valor_issrf','//VlIss', '//ValorIss', '//Field[@Name="ForValorISS2"]/Value']
  XPATH_VALOR_ISS_RETIDO = ['//ImpostosRetidos/VlrIssRetido'  , '//NOTA/VL_ISS_RETIDO', '//valor_iss_retido', '//Iss/Vlr', '//Servico/Valores/ValorIssRetido', '//Field[@Name="forValorISSRetido1"]/Value', '//ValorIssRetido', '//Servico/valores/valorIssRetido', '//VALOR_ISS_RET', '//valorIss', '//VlIssRet','//NfeValISsRetido', '//impostos/valor_iss','//itens/lista/valor_issrf','//valorIssRetido']

  XPATH_DISCRIMINACAO     =  ['//Discriminacao', '//nf-e/obs', '//Observacao', '//discriminacao', '//infAdic/infAdFisco', '//DescricaoTipoServico', '//ITENS/Servico', '//NOTA/DISCRIMINACAO', '//descricaoNota','//tsObsNfe', '//tsDesSvc', '//tsDesItem', '//Servicos/Descricao']
  XPATH_CODIGO_MUNICIPIO_PRESTACAO = ['//atividadeExecutada/localPrestacao/descricaoMunicipio','//Servico/CodigoMunicipio', '//DeclaracaoPrestacaoServico/CodigoMunicipio', '//municipioIncidencia', '//MunicipioPrestacaoServico', '//municipio_prestacao_servico', '//ide/cMunFG', '//servicoCidade', ['//NOTA/OUTRAS_INFORMACOES', /^município de prestação: (.*)$/i], '//localPrestacao/descricaoMunicipio', '//tcInfNFE/tsMunSvc', '//DadosTomador/Endereco/CodigoMunicipio', '//LocalPrestacao']

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
    ret = '<CompNfse xmlns="http://www.abrasf.org.br/nfse.xsd">'
    ret << build_Nfse(xml)
    ret << '</CompNfse>'
    ret
  end

  def self.build_Nfse(xml)
    ret = '<Nfse versao="1.00">'
    ret << build_InfNfse(xml)
    ret << build_Signature(xml)
    ret << build_Pedido(xml)
    ret << '</Nfse>'
    ret
  end

  def self.build_InfNfse(xml)
    ret = '<InfNfse Id="nfse">'
    ret << build_InfNfse_LocalPrestacao(xml)
    ret << build_InfNfse_Numero(xml)
    ret << build_InfNfse_CodigoVerificacao(xml)
    ret << build_InfNfse_DataEmissao(xml)
    ret << build_InfNfse_IdentificacaoRps(xml)
    ret << build_InfNfse_DataEmissaoRps(xml)
    ret << build_InfNfse_NaturezaOperacao(xml)
    ret << build_InfNfse_OptanteSimplesNacional(xml)
    ret << build_InfNfse_IncentivadorCultural(xml)
    ret << build_InfNfse_Competencia(xml)
    ret << build_InfNfse_Servico(xml)
    ret << build_InfNfse_ConstrucaoCivil(xml)
    ret << build_InfNfse_PrestadorServico(xml)
    ret << build_InfNfse_TomadorServico(xml)
    ret << build_InfNfse_OrgaoGerador(xml)
    ret << '</InfNfse>'

    ret
  end


  def self.build_InfNfse_LocalPrestacao(xml)
    build_tag('LocalPrestacao',xml, '//LocalPrestacao')
  end


  def self.build_InfNfse_Numero(xml)
    build_tag_numero_nfse(xml, '//InfNfse/Numero', '//nf-e/numero', '//NumeroNota', '//item/numero', '//IdentificacaoNfse/Numero', '//nNF', '//Numero', '//Field[@Name="ForNumNota3"]/FormattedValue', '//NOTA/NUMERO', '//numeroNota', '//tsNumNot')
  end

  def self.build_InfNfse_CodigoVerificacao(xml)
    build_tag("CodigoVerificacao", xml, '//CodigoVerificacao', '//ChaveValidacao', '//codigo_verificacao', '//senha', '//infProt/chNFe', '//NOTA/CD_VERIFICACAO', '//codigoVerificacao', '//tsCodVer')
  end

  def self.build_InfNfse_DataEmissao(xml)
    build_tag("DataEmissao", xml, '//DataEmissao', '//nf-e/prestacao', '//data_emissao', '//dhEmi', '//DtEmissao', '//NOTA/DT_COMPETENCIA', '//dtEmissao', '//tsDatEms')
  end

  def self.build_InfNfse_IdentificacaoRps(xml)
    ret = '<IdentificacaoRps>'
    ret << build_InfNfse_IdentificacaoRps_Numero(xml)
    ret << build_InfNfse_IdentificacaoRps_Serie(xml)
    ret << build_InfNfse_IdentificacaoRps_Tipo(xml)
    ret << '</IdentificacaoRps>'
    ret
  end

  def self.build_InfNfse_IdentificacaoRps_Numero(xml)
    build_tag("Numero", xml, '//IdentificacaoRps/Numero', '//numero_rps', '//tsNumRps','//IdentificacaoNfse/NumeroRps')
  end

  def self.build_InfNfse_IdentificacaoRps_Serie(xml)
    build_tag("Serie", xml, '//IdentificacaoRps/Serie', '//IdentificacaoNfse/Serie')
  end

  def self.build_InfNfse_IdentificacaoRps_Tipo(xml)
    build_tag("Tipo", xml, '//IdentificacaoRps/Tipo', '//IdentificacaoNfse/Tipo')
  end

  def self.build_InfNfse_DataEmissaoRps(xml)
    build_tag("DataEmissaoRps", xml, '//InfNfse/DataEmissaoRps', '//Rps/DataEmissao', '//data_emissao_rps')
  end

  def self.build_InfNfse_NaturezaOperacao(xml)
    build_tag("NaturezaOperacao", xml, '//NaturezaOperacao', '//natureza_operacao', '//NOTA/CD_NATUREZA_OPERACAO', '//dtEmissao', '//tsNatOpe')
  end

  def self.build_InfNfse_OptanteSimplesNacional(xml)
    build_tag("OptanteSimplesNacional", xml, '//DadosPrestador/OptanteSimplesNacional','//OptanteSimplesNacional', '//optante_simples_nacional', '//NOTA/SN_OPTANTE_SIMPLES_NACIONAL', '//tsOptSN')
  end

  def self.build_InfNfse_IncentivadorCultural(xml)
    build_tag("IncentivadorCultural", xml, '//IncentivadorCultural', '//incentivador_cultural')
  end

  def self.build_InfNfse_Competencia(xml)
    build_tag("Competencia", xml, '//Competencia', '//nf-e/prestacao', '//competencia', '//DtPrestacaoServico', '//NOTA/DT_COMPETENCIA')
  end

  def self.build_InfNfse_Servico(xml)
    ret = '<Servico>'
    ret << build_InfNfse_Servico_Valores(xml)
    ret << build_InfNfse_Servico_ItemListaServico(xml)
    ret << build_InfNfse_Servico_CodigoTributacaoMunicipio(xml)
    ret << build_InfNfse_Servico_CodigoMunicipio(xml)
    ret << build_InfNfse_Servico_UF(xml)
    ret << build_InfNfse_Servico_Quantidade(xml)
    ret << build_InfNfse_Servico_Unidade(xml)
    ret << build_InfNfse_Servico_ValorDesconto(xml)
    ret << build_InfNfse_Servico_ValorIssqn(xml)
    ret << '</Servico>'

    ret
  end

  def self.build_InfNfse_Servico_Valores(xml)
    ret = '<Valores>'
    ret << build_InfNfse_Servico_Valores_ValorServicos(xml)
    ret << build_InfNfse_Servico_Valores_ValorPis(xml)
    ret << build_InfNfse_Servico_Valores_ValorCofins(xml)
    ret << build_InfNfse_Servico_Valores_ValorIr(xml)
    ret << build_InfNfse_Servico_Valores_ValorCsll(xml)
    ret << build_InfNfse_Servico_Valores_IssRetido(xml)
    ret << build_InfNfse_Servico_Valores_ValorIss(xml)
    ret << build_InfNfse_Servico_Valores_ValorInss(xml)
    ret << build_InfNfse_Servico_Valores_BaseCalculo(xml)
    ret << build_InfNfse_Servico_Valores_Aliquota(xml)
    ret << build_InfNfse_Servico_Valores_ValorLiquidoNfse(xml)
    ret << build_InfNfse_Servico_Valores_ValorDeducoes(xml)
    ret << build_InfNfse_Servico_Valores_OutrosDecontos(xml)
    ret << '</Valores>'

    ret
  end

  def self.build_InfNfse_Servico_Valores_ValorServicos(xml)
    build_tag("ValorServicos", xml, *XPATH_VALOR_SERVICO)
  end

  def self.build_InfNfse_Servico_Valores_ValorPis(xml)
    build_tag("ValorPis", xml, '//Servico/Valores/ValorPis', '//Valores/ValorPis', '//deducao[@codigo="PIS"]', '//Pis', '//valor_pis', '//vPIS', '//ImpostosRetidos/VlrPisPasep', '//Field[@Name="VlrPIS1"]/Value', '//NOTA/VL_PIS', '//imposto[@nItem="1"]/valorImposto', 'tsVlrPIS')
  end

  def self.build_InfNfse_Servico_Valores_ValorCofins(xml)
    build_tag("ValorCofins", xml, '//Servico/Valores/ValorCofins', '//Valores/ValorCofins', '//deducao[@codigo="COFINS"]', '//Cofins', '//valor_confins', '//vCOFINS', '//ImpostosRetidos/VlrCofins', '//Field[@Name="VlrCOFINS1"]/Value', '//NOTA/VL_COFINS', '//imposto[@nItem="2"]/valorImposto', '//tsVlrCOFINS')
  end

  def self.build_InfNfse_Servico_Valores_ValorIr(xml)
    build_tag("ValorIr", xml, '//Servico/Valores/ValorIr', '//Valores/ValorIr', '//Irrf', '//valor_ir', '//vIRRF', '//ImpostosRetidos/VlrIrrf', '//Field[@Name="VlrIR1"]/Value', '//NOTA/VL_IR', '//imposto[@nItem="4"]/valorImposto', '//tsVlrIR')
  end

  def self.build_InfNfse_Servico_Valores_ValorCsll(xml)
    build_tag("ValorCsll", xml, '//Servico/Valores/ValorCsll', '//Valores/ValorCsll', '//deducao[@codigo="CSLL"]', '//Csll', '//valor_csll', '//vRetCSLL', '//ImpostosRetidos/VlrCsll', '//Field[@Name="VlrCSLL1"]/Value', '//NOTA/VL_CSLL', '//imposto[@nItem="5"]/valorImposto', '//tsVlrCSLL')
  end

  def self.build_InfNfse_Servico_Valores_IssRetido(xml)
    xpath = ['//IssRetido', '//retido', '//iss_retido', '//cRegTrib', '//NOTA/SN_ISS_RETIDO', '//tsISSRtn', '//Servico/valores/issRetido', '//issretido', '//tsFrmRec', '//ISSRetido','//ISSRetido','//impostos/iss_retido']
    if value(xml, *xpath)
      build_tag("IssRetido", xml, *xpath)
    else
      valor_iss = value(xml, *XPATH_VALOR_ISS)
      valor_iss_retido = value(xml, *XPATH_VALOR_ISS_RETIDO)
      if valor_iss_retido.blank? and valor_iss.blank?
        "<IssRetido></IssRetido>"
      elsif valor_iss_retido.to_i > 0 or valor_iss.to_i > 0
        "<IssRetido>1</IssRetido>"
      else
        "<IssRetido>2</IssRetido>"
      end
    end
  end

  def self.build_InfNfse_Servico_Valores_ValorIss(xml)
    build_tag("ValorIss", xml, *XPATH_VALOR_ISS)
  end

  def self.build_InfNfse_Servico_Valores_ValorInss(xml)
    build_tag("ValorInss", xml, '//ValorInss', '//Field[@Name="VlrINSS1"]/Value', '//NOTA/VL_INSS', '//imposto[@nItem="3"]/valorImposto', '//Inss', '//tsVlrINSS')
  end

  def self.build_InfNfse_Servico_Valores_BaseCalculo(xml)
    build_tag("BaseCalculo", xml, '//InfNfse/ValoresNfse/BaseCalculo', '//InfNfse/Servico/Valores/BaseCalculo', '//valorBase', '//BaseCalculo', '//base_calculo', '//total/ISSQNtot/vBC', '//Iss/BaseCalculo', '//NOTA/VL_BASE_CALCULO', '//valorReducaoBC', '//tsBasCalc')
  end

  def self.build_InfNfse_Servico_Valores_Aliquota(xml)
    build_tag("Aliquota", xml, '//Servico/Valores/Aliquota', '//Valores/Aliquota', '//nf-e/aliquota', '//aliquota_servico', '//vAliq', '//Iss/Aliquota', '//Field[@Name="PERALQ2"]/Value', '//NOTA/VL_ALIQUOTA', '//atividadeExecutada/aliquota', '//tsPerAlq', '//ITENS/Aliquota','//Servicos/Aliquota')
  end

  def self.build_InfNfse_Servico_Valores_ValorLiquidoNfse(xml)
    xpaths = ['//InfNfse/ValoresNfse/ValorLiquidoNfse', '//Servico/Valores/ValorLiquidoNfse', '//valorLiquido', '//ValorTotalNota', '//valor_liquido_nfse', '//total/ICMSTot/vProd', '//VlrLiquido', '//Field[@Name="forValorLiquido1"]/Value', '//NOTA/VL_LIQUIDO_NFSE', '//valorTotalServico', '//tsVlrLiq']
    if value(xml, *xpaths)
      build_tag("ValorLiquidoNfse", xml, *xpaths)
    else
      build_tag("ValorLiquidoNfse", xml, *XPATH_VALOR_SERVICO)
    end
  end

  def self.build_InfNfse_Servico_Valores_ValorDeducoes(xml)
    build_tag("ValorDeducoes", xml, '//Valores/ValorDeducoes','//Servicos/Valores/ValorDeducoes', '//tsVlrDed', '//totais/valorTotalDeducao')
  end

  def self.build_InfNfse_Servico_Valores_OutrosDecontos(xml)
    build_tag("OutrosDescontos", xml, '//Valores/OutrosDescontos','//Servicos/Valores/OutrosDescontos')
  end

  def self.build_InfNfse_Servico_ItemListaServico(xml)
    value             = self.value(xml, '//Servicos/CodigoServicoMunicipal', '//ItemListaServico', ['//nf-e/atividade', /(\d*\d\.\d\d)/], '//Cae', '//item_lista_servico', '//det//cProd', ['//DescricaoTipoServico', /(\d*\d\.\d\d)/], ['//Field[@Name="ForServico1"]/Value', /(\d\d.\d\d|\d.\d\d)/], '//NOTA/ES_ITEM_LISTA_SERVICO', '//atividadeExecutada/codigoServico', '//tsCodSvc', '//ItemServico')
    municipio_gerador = ibge_code(self.value(xml, *XPATH_MUNICIPIO_GERADOR)) ||
                        ibge_code(self.value(xml, *XPATH_MUNICIPIO_PRESTADOR))
    CSV.foreach(File.join(File.dirname(__FILE__), 'de_para_lc.csv'), col_sep: ";") do |row|
      if row[0] == municipio_gerador
        if row[1].gsub('.', '') == value.to_s.gsub('.', '').to_i.to_s
          value = row[2]
          break
        end
      end
    end

    if value
      "<ItemListaServico>#{'%.2f' % (value.to_s.gsub('.', '').to_f/100) }</ItemListaServico>"
    else
      "<ItemListaServico />"
    end
  end

  def self.build_InfNfse_Servico_CodigoTributacaoMunicipio(xml)
    build_tag("CodigoTributacaoMunicipio", xml, '//CodigoTributacaoMunicipio', '//codigo_tributacao_municipio', '//NOTA/CD_TRIBUTACAO_MUNICIPIO')
  end


  def self.build_InfNfse_Servico_Quantidade(xml)
    build_tag("Quantidade", xml, '//Servicos/Quantidade')
  end

  def self.build_InfNfse_Servico_Unidade(xml)
    build_tag("Unidade", xml, '//Servicos/Unidade')
  end

  def self.build_InfNfse_Servico_ValorDesconto(xml)
    build_tag("ValorDesconto", xml, '//Servicos/ValorDesconto', '//tsVlrDsc', '//Field[@Name="ForValorDesconto3"]/Value')
  end

  def self.build_InfNfse_Servico_ValorIssqn(xml)
    build_tag("ValorIssqn", xml, '//Servicos/ValorIssqn', '//tsVlrISSQN')
  end

  def self.build_InfNfse_Servico_CodigoMunicipio(xml)
    xpaths = XPATH_CODIGO_MUNICIPIO_PRESTACAO
    build_codigo_municipio(xml, *xpaths)
  end

  def self.build_InfNfse_Servico_UF(xml)
    codigo_municipio = ibge_code(value(xml, *XPATH_CODIGO_MUNICIPIO_PRESTACAO))
    if codigo_municipio.to_i > 0
      codigo_municipio = codigo_municipio.to_s[0..1]

      if tag_value = UF[codigo_municipio]
        "<Uf>#{tag_value}</Uf>"
      else
        "<Uf />"
      end
    else
      "<Uf />"
    end
  end

  def self.build_InfNfse_ConstrucaoCivil(xml)
    ret = '<ConstrucaoCivil>'
    ret << build_InfNfse_ConstrucaoCivil_CodigoObra(xml)
    ret << '</ConstrucaoCivil>'

    ret
  end

  def self.build_InfNfse_ConstrucaoCivil_CodigoObra(xml)
    build_tag("CodigoObra", xml, '//CodigoObra')
  end

  def self.build_InfNfse_PrestadorServico(xml)
    ret = '<PrestadorServico>'
    ret << build_InfNfse_PrestadorServico_IdentificacaoPrestador(xml)
    ret << build_InfNfse_PrestadorServico_RazaoSocial(xml)
    ret << build_InfNfse_PrestadorServico_NomeFantasia(xml)
    ret << build_InfNfse_PrestadorServico_Endereco(xml)
    ret << build_InfNfse_PrestadorServico_Contato(xml)
    ret << build_InfNfse_PrestadorServico_RegimeEspecialTributacao(xml)
    ret << '</PrestadorServico>'
    ret
  end

  def self.build_InfNfse_PrestadorServico_IdentificacaoPrestador(xml)
    ret = '<IdentificacaoPrestador>'
    ret << build_InfNfse_PrestadorServico_Cnpj(xml)
    ret << build_InfNfse_PrestadorServico_InscricaoMunicipal(xml)
    ret << '</IdentificacaoPrestador>'
  end

  def self.build_InfNfse_PrestadorServico_Cnpj(xml)
    build_tag("Cnpj", xml, '//DadosPrestador/IdentificacaoPrestador/CpfCnpj', '//PrestadorServico/IdentificacaoPrestador//Cnpj', '//IdentificacaoPrestador/Cnpj', '//prestador/documento', '//prestacao_servico//cnpj', '//emit/CNPJ', '//DadosPrestador/Cnpj', '//Field[@Name="ForCPFCNPJPrestador2"]/Value', /cpf\/cnpj: (\d\d\.\d\d\d\.\d\d\d\/\d\d\d\d\-\d\d)/i, '//NOTA/CNPJ', '//prestador/cnpj', '//tsNumDocPtd', '//CnpjPrestador', '//CPFCNPJPrestador')
  end

  def self.build_InfNfse_PrestadorServico_InscricaoMunicipal(xml)
    build_tag("InscricaoMunicipal", xml,'//DadosPrestador/IdentificacaoPrestador/InscricaoMunicipal', '//PrestadorServico/IdentificacaoPrestador/InscricaoMunicipal', '//prestacao_servico//inscricao_municipal', /municipal:\s(\d+)\s/i, '//emit/IM', '//DadosPrestador/InscricaoMunicipal', '//Field[@Name="CODCADBIC2"]/Value', '//NOTA/INSCRICAO_MUNICIPAL', '//prestador/inscricaoMunicipal', '//tsInsMunPtd')
  end

  def self.build_InfNfse_PrestadorServico_RazaoSocial(xml)
    build_tag("RazaoSocial", xml, '//PrestadorServico/RazaoSocial', '//prestador/nome', '//TimbreContribuinteLinha1', '//prestacao_servico//razao_social', '//emit/xNome', '//DadosPrestador/RazaoSocial', '//Field[@Name="forNomCrb451"]/Value', '//NOTA/PRE_RAZAO_SOCIAL', '//prestador/razaoSocial', '//tsNomPtd')
  end

  def self.build_InfNfse_PrestadorServico_NomeFantasia(xml)
    build_tag("NomeFantasia", xml, '//PrestadorServico/NomeFantasia', '//prestacao_servico//nome_fantasia', '//emit/xFant', '//DadosPrestador/NomeFantasia', '//NOTA/PRE_NOME_FANTASIA', '//tsNomPtd')
  end

  def self.build_InfNfse_PrestadorServico_Endereco(xml)
    ret = '<Endereco>'
    ret << build_InfNfse_PrestadorServico_Endereco_Endereco(xml)
    ret << build_InfNfse_PrestadorServico_Endereco_Numero(xml)
    ret << build_InfNfse_PrestadorServico_Endereco_Complemento(xml)
    ret << build_InfNfse_PrestadorServico_Endereco_Bairro(xml)
    ret << build_InfNfse_PrestadorServico_Endereco_CodigoMunicipio(xml)
    ret << build_InfNfse_PrestadorServico_Endereco_Municipio(xml)
    ret << build_InfNfse_PrestadorServico_Endereco_Uf(xml)
    ret << build_InfNfse_PrestadorServico_Endereco_Cep(xml)
    ret << '</Endereco>'

    ret
  end

  def self.build_InfNfse_PrestadorServico_Endereco_Endereco(xml)
    build_tag("Endereco", xml,'//DadosPrestador/Endereco/Logradouro', '//PrestadorServico/Endereco/Endereco', '//prestador/logradouro', '//prestacao_servico//logradouro', ['//TimbreContribuinteLinha2', /(.+),/], '//enderEmit/xLgr', '//DadosPrestador/Endereco/Endereco', '//NOTA/PRE_ENDERECO', '//prestador/endereco/logradouro', '//tsEndPtd', '//PrestadorServico/Endereco/Rua')
  end

  def self.build_InfNfse_PrestadorServico_Endereco_Numero(xml)
    build_tag("Numero", xml,'//DadosPrestador/Endereco/LogradouroNumero', '//PrestadorServico/Endereco/Numero', '//prestador/numero', '//prestacao_servico//numero', ['//TimbreContribuinteLinha2', /,\s(.+)\s-/], '//enderEmit/nro', '//DadosPrestador/Endereco/Numero', '//NOTA/PRE_ENDERECO_NUMERO')
  end

  def self.build_InfNfse_PrestadorServico_Endereco_Complemento(xml)
    build_tag("Complemento", xml, '//DadosPrestador/Endereco/LogradouroComplemento', '//PrestadorServico/Endereco/Complemento', '//prestacao_servico//complemento', '//enderEmit/xCpl', '//DadosPrestador/Endereco/Complemento', '//NOTA/PRE_ENDERECO_COMPLEMENTO')
  end

  def self.build_InfNfse_PrestadorServico_Endereco_Bairro(xml)
    build_tag("Bairro", xml, '//DadosPrestador/Endereco/Bairro','//PrestadorServico/Endereco/Bairro', '//prestador/bairro', '//prestacao_servico//bairro', ['//TimbreContribuinteLinha2', /-\s(.+)$/], '//enderEmit/xBairro', '//DadosPrestador/Endereco/Bairro', '//NOTA/PRE_ENDERECO_BAIRRO', '//prestador/endereco/bairro', '//tsBaiPtd')
  end

  def self.build_InfNfse_PrestadorServico_Endereco_CodigoMunicipio(xml)
    build_codigo_municipio(xml, *XPATH_MUNICIPIO_PRESTADOR)
  end

  def self.build_InfNfse_PrestadorServico_Endereco_Municipio(xml)
    build_tag('Municipio',xml, '//DadosPrestador/Endereco/Municipio', '//prestador/endereco/descricaoMunicipio  ')
  end

  def self.build_InfNfse_PrestadorServico_Endereco_Uf(xml)
    build_tag("Uf", xml, '//PrestadorServico/Endereco/Uf', '//prestador/estado', '//prestacao_servico//uf', ['//TimbreContribuinteLinha3', /- .+ -\s(.+)$/], '//enderEmit/UF', '//DadosPrestador/Endereco/Uf', '//NOTA/PRE_ENDERECO_UF', '//prestador/endereco/codigoEstado', '//tsEstPtd', '//PrestadorServico/Endereco/Estado')
  end

  def self.build_InfNfse_PrestadorServico_Endereco_Cep(xml)
    build_tag("Cep", xml, '//PrestadorServico/Endereco/Cep', '//prestador/cep', '//prestacao_servico//cep', ['//TimbreContribuinteLinha3', /cep\s(\d\d\d\d\d-\d\d\d)/i], '//enderEmit/CEP', '//NOTA/PRE_ENDERECO_CEP', '//prestador/endereco/cep', '//tsCepPtd', '//DadosPrestador/Endereco/Cep')
  end

  def self.build_InfNfse_PrestadorServico_Contato(xml)
    ret = '<Contato>'
    ret << build_InfNfse_PrestadorServico_Contato_Telefone(xml)
    ret << build_InfNfse_PrestadorServico_Contato_Email(xml)
    ret << '</Contato>'

    ret
  end

  def self.build_InfNfse_PrestadorServico_Contato_Telefone(xml)
    build_tag("Telefone", xml, '//PrestadorServico/Contato/Telefone', '//prestador/telefone', '//prestacao_servico//telefone', '//enderEmit/fone', '//NOTA/PRE_TELEFONE', '//prestador/telefoneNumero', '//DadosPrestador/Contato/Telefone')
  end

  def self.build_InfNfse_PrestadorServico_Contato_Email(xml)
    build_tag("Email", xml, '//PrestadorServico/Contato/Email', '//prestador/email', '//prestacao_servico//email','//DadosPrestador/Contato/Email')
  end

  def self.build_InfNfse_PrestadorServico_RegimeEspecialTributacao(xml)
    build_tag("RegimeEspecialTributacao", xml, '//DadosPrestador/RegimeEspecialTributacao', '//RegimeEspecialTributacao')
  end

  def self.build_InfNfse_TomadorServico(xml)
    ret = '<TomadorServico>'
    ret << build_InfNfse_TomadorServico_IdentificacaoTomador(xml)
    ret << build_InfNfse_TomadorServico_RazaoSocial(xml)
    ret << build_InfNfse_TomadorServico_NomeFantasia(xml)
    ret << build_InfNfse_TomadorServico_Endereco(xml)
    ret << build_InfNfse_TomadorServico_Contato(xml)
    ret << '</TomadorServico>'

    ret
  end

  def self.build_InfNfse_TomadorServico_IdentificacaoTomador(xml)
    ret = '<IdentificacaoTomador>'
    ret << build_InfNfse_IdentificacaoTomador_CpfCnpj(xml)
    ret << '</IdentificacaoTomador>'
  end

  def self.build_InfNfse_IdentificacaoTomador_CpfCnpj(xml)
    ret = '<CpfCnpj>'
    ret << build_InfNfse_IdentificacaoTomador_CpfCnpj_Cnpj(xml)
    ret << '</CpfCnpj>'
  end

  def self.build_InfNfse_IdentificacaoTomador_CpfCnpj_Cnpj(xml)
    build_tag("Cnpj", xml, '//DadosTomador/IdentificacaoTomador/CpfCnpj', '//IdentificacaoTomador//Cnpj', '//tomador/documento', '//ClienteCNPJCPF', '//clienteCNPJCPF', '//tomador_servico//cpf_cnpj', '//dest/CNPJ', '//DadosTomador/Cnpj', ['//Text[@Name="Text7"]/TextValue', /cpf\/cnpj: (\d\d\.\d\d\d\.\d\d\d\/\d\d\d\d\-\d\d)/i], '//NOTA/TOM_CPF_CNPJ', '//tomador/cnpj', '//tsNumDocTmd', '//Tomador/CnpjCpf', '//CPFCNPJTomador')
  end

  def self.build_InfNfse_TomadorServico_RazaoSocial(xml)
    build_tag("RazaoSocial", xml, '//Tomador/RazaoSocial', '//tomador/nome', '//TomadorServico/RazaoSocial', '//ClienteNomeRazaoSocial', '//tomador_servico//razao_social', '//dest/xNome', '//DadosTomador/RazaoSocial', ['//Text[@Name="Text6"]/TextValue', /nome\/razão social: (.*)$/i], '//NOTA/TOM_RAZAO_SOCIAL', '//tomador/razaoSocial', '//tsNomTmd')
  end

  def self.build_InfNfse_TomadorServico_NomeFantasia(xml)
    build_tag("NomeFantasia", xml, '//DadosTomador/NomeFantasia', '//PrestadorServico/NomeFantasia')
  end

  def self.build_InfNfse_TomadorServico_Endereco(xml)
    ret = '<Endereco>'
    ret << build_InfNfse_TomadorServico_Endereco_Endereco(xml)
    ret << build_InfNfse_TomadorServico_Endereco_Numero(xml)
    ret << build_InfNfse_TomadorServico_Endereco_Bairro(xml)
    ret << build_InfNfse_TomadorServico_Endereco_CodigoMunicipio(xml)
    ret << build_InfNfse_TomadorServico_Endereco_Municipio(xml)
    ret << build_InfNfse_TomadorServico_Endereco_Uf(xml)
    ret << build_InfNfse_TomadorServico_Endereco_Cep(xml)
    ret << '</Endereco>'
  end

  def self.build_InfNfse_TomadorServico_Endereco_Endereco(xml)
    build_tag("Endereco", xml, '//Tomador/Endereco/Endereco', '//TomadorServico/Endereco/Endereco', '//tomador/logradouro', '//ClienteEndereco', '//tomador_servico//lograrouro', '//enderDest/xLgr', '//DadosTomador/Endereco/Endereco', '//NOTA/TOM_ENDERECO', '//tomador/endereco/logradouro', '//tsEndTmd')
  end

  def self.build_InfNfse_TomadorServico_Endereco_Numero(xml)
    build_tag("Numero", xml, '//Tomador/Endereco/Numero', '//TomadorServico/Endereco/Numero', '//tomador/numero', '//ClienteNumeroLogradouro', '//tomador_servico//numero', '//enderDest/nro', '//DadosTomador/Endereco/Numero', '//NOTA/TOM_ENDERECO_NUMERO')
  end

  def self.build_InfNfse_TomadorServico_Endereco_Bairro(xml)
    build_tag("Bairro", xml, '//Tomador/Endereco/Bairro', '//TomadorServico/Endereco/Bairro', '//tomador/bairro', '//ClienteBairro', '//tomador_servico//bairro', '//enderDest/xBairro', '//DadosTomador/Endereco/Bairro', ['//Field[@Name="ForEndBaiTomador1"]/Value', /^.* - (.*)$/], '//NOTA/TOM_ENDERECO_BAIRRO', '//tomador/endereco/bairro', '//tsBaiTmd')
  end

  def self.build_InfNfse_TomadorServico_Endereco_CodigoMunicipio(xml)
    xpaths = ['//Tomador/Endereco/CodigoMunicipio', '//TomadorServico/Endereco/CodigoMunicipio', '//tomador_servico//codigo_municipio', '//enderDest/cMun', '//DadosTomador/Endereco/Municipio', '//Field[@Name="forCidadeEstadoTomador1"]/Value', '//NOTA/TOM_ENDERECO_ES_MUNICIPIO', '//tomador/endereco/descricaoMunicipio', '//tsMunTmd']
    build_codigo_municipio(xml, *xpaths)
  end

  def self.build_InfNfse_TomadorServico_Endereco_Municipio(xml)
    build_tag('Municipio',xml, '//DadosTomador/Endereco/Municipio','//Field[@Name="forCidadeEstadoTomador1"]/Value', '//tomador/endereco/descricaoMunicipio')
  end

  def self.build_InfNfse_TomadorServico_Endereco_Uf(xml)
    build_tag("Uf", xml, '//Tomador/Endereco/Uf', '//TomadorServico/Endereco/Uf', '//tomador/estado', '//ClienteUF', '//tomador_servico//uf', '//enderDest/UF', '//DadosTomador/Endereco/Uf', '//NOTA/TOM_ENDERECO_UF', '//tomador/endereco/codigoEstado', '//tsEstTmd')
  end

  def self.build_InfNfse_TomadorServico_Endereco_Cep(xml)
    build_tag("Cep", xml, '//Tomador/Endereco/Cep', '//TomadorServico/Endereco/Cep', '//tomador/cep', '//ClienteCEP', '//tomador_servico//cep', '//enderDest/CEP', '//Field[@Name="CepDst1"]/Value', '//NOTA/TOM_ENDERECO_CEP', '//tomador/endereco/cep', '//tsCepTmd','//DadosTomador/Endereco/Cep')
  end

  def self.build_InfNfse_TomadorServico_Contato(xml)
    ret = '<Contato>'
    ret << build_InfNfse_TomadorServico_Contato_Telefone(xml)
    ret << build_InfNfse_TomadorServico_Contato_Email(xml)
    ret << '</Contato>'

    ret
  end

  def self.build_InfNfse_TomadorServico_Contato_Telefone(xml)
    build_tag("Telefone", xml, '//Tomador//Telefone', '//TomadorServico//Telefone', '//tomador_servico//telefone', '//NOTA/TOM_TELEFONE', '//tomador/telefoneNumero')
  end

  def self.build_InfNfse_TomadorServico_Contato_Email(xml)
    build_tag("Email", xml, '//Tomador//Email', '//TomadorServico//Email', '//ClienteEmail', '//tomador_servico//email', '//dest/email', '//NOTA/TOM_EMAIL','//DadosTomador/Contato/Email')
  end

  def self.build_InfNfse_OrgaoGerador(xml)
    ret = '<OrgaoGerador>'
    ret << build_InfNfse_OrgaoGerador_CodigoMunicipio(xml)
    ret << build_InfNfse_OrgaoGerador_Uf(xml)
    ret << '</OrgaoGerador>'

    ret
  end

  def self.build_InfNfse_OrgaoGerador_CodigoMunicipio(xml)
    build_codigo_municipio(xml, *XPATH_MUNICIPIO_GERADOR)
  end

  def self.build_InfNfse_OrgaoGerador_Uf(xml)
    xpath = ['//OrgaoGerador/Uf', '//orgao_gerador/uf', '//enderEmit/UF', '//NOTA/ORGAO_GERADOR_UF', '//tomador/telefoneNumero']
    if value(xml, *xpath)
      build_tag("Uf", xml, *xpath)
    else
      codigo_municipio = ibge_code(value(xml, *XPATH_MUNICIPIO_GERADOR))

      if codigo_municipio.to_i > 0
        codigo_municipio = codigo_municipio.to_s[0..1]

        if tag_value = UF[codigo_municipio]
          "<Uf>#{tag_value}</Uf>"
        else
          "<Uf />"
        end
      else
        "<Uf />"
      end
    end
  end

  def self.build_Signature(xml)
    ret = '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#" Id="NfseAssSMF_nfse">'
    ret << '<SignedInfo>'
    ret << '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
    ret << '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
    ret << '<Reference URI="#nfse">'
    ret << '<Transforms>'
    ret << '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
    ret << '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
    ret << '</Transforms>'
    ret << '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
    ret << '<DigestValue>IDctIj4P0NsYgLf8VP2z0GJkveM=</DigestValue>'
    ret << '</Reference>'
    ret << '</SignedInfo>'
    ret << '<SignatureValue>cOLhW920L/fn2jndH3pFd9LMsCFjQ/+h8TfmV5lcz8Qc33njBe3W39alrZTRPdpmn0CcaWG4bu2vvihRsX0HzDztPyBqUs9BF/YIdtKTfDfOlAA7heuaBo8FLaXcbI0TdGJNK5dbYEavbtrqP97ReEozKP/aEjaK8KUlS2KLXgZb5t9mM172l4DarhuVYBY9QTmuyvtlP1lv7OnjI9I+PnuSDKVEGeHZfQQH51EJSEOku4v/YWQkYh9wbVlzZj+JrWSWtkmexomO8cmP9DBq1lcU3lwPsWMyTYesE0xteRHG1KHYJakVH1wJcKu8zxdxmkbGyRASWFgAiJm9Iw2lPQ==</SignatureValue>'
    ret << '<KeyInfo>'
    ret << '<X509Data>'
    ret << '<X509Certificate>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</X509Certificate>'
    ret << '</X509Data>'
    ret << '</KeyInfo>'
    ret << '</Signature>'

    ret
  end

  def self.build_Pedido(xml)
    ret = '<Pedido>'
    ret << build_Pedido_Contrato(xml)
    ret << build_Pedido_Pedido(xml)
    ret << build_Pedido_FRS(xml)
    ret << build_Pedido_RF(xml)
    ret << build_Pedido_ASN(xml)
    ret << build_Pedido_ColetaINT(xml)
    ret << build_Pedido_Discriminacao(xml)

    ret << '</Pedido>'
    ret
  end

  def self.build_Pedido_Contrato(xml)
    build_tag("Contrato", xml, *(XPATH_DISCRIMINACAO | ['//Field[@Name="DesSvc82"]/Value'] ).map { |d| [d, /[^\d]((?:44|46|55|59)\d{8})[^\d]/] })
  end

  def self.build_Pedido_Pedido(xml)
    build_tag("Pedido", xml, *(XPATH_DISCRIMINACAO | ['//Field[@Name="DesSvc72"]/Value'] ).map { |d| [d, /[^\d]((?:45|41|47)\d{8})[^\d]/] })
  end

  def self.build_Pedido_FRS(xml)
    build_tag("FRS", xml, *(XPATH_DISCRIMINACAO | ['//Field[@Name="DesSvc92"]/Value'] ).map { |d| [d, /[^\d]((?:10)\d{8})[^\d]/] })
  end

  def self.build_Pedido_RF(xml)
    build_tag("RF", xml, *(XPATH_DISCRIMINACAO | ['//Field[@Name="DesSvc102"]/Value'] ).map { |d| [d, /[^\d]((?:62)\d{8})[^\d]/] })
  end

  def self.build_Pedido_ASN(xml)
    build_tag("ASN", xml, *(XPATH_DISCRIMINACAO | ['//Field[@Name="OBSNFE2"]/Value'] ).map { |d| [d, /[^\d](([A-Z])\d{9})[^\d]/] })
  end

  def self.build_Pedido_ColetaINT(xml)
    build_tag("ColetaINT", xml, *(XPATH_DISCRIMINACAO | ['//Field[@Name="OBSNFE2"]/Value'] ).map { |d| [d, /((\d{3})\.\d{6})/] })
  end

  def self.build_Pedido_Discriminacao(xml)
    build_tag("Discriminacao", xml, *XPATH_DISCRIMINACAO | ['//Field[@Name="OBSNFE2"]/Value'])
  end

  def self.build_codigo_municipio(xml, *xpaths)
    if codigo_municipio = value(xml, *xpaths)
      codigo_municipio = ibge_code(codigo_municipio)

      "<CodigoMunicipio>#{codigo_municipio}</CodigoMunicipio>"
    else
      "<CodigoMunicipio />"
    end
  end

  def self.ibge_code(codigo_municipio)
    CSV.foreach(File.join(File.dirname(__FILE__), 'de_para_cidade_ibge.csv'), col_sep: ";") do |row|
      if I18n.transliterate(row[0]).downcase == I18n.transliterate(codigo_municipio.to_s.gsub(/\s+/, ' ')).downcase
        return row[1]
      end
    end

    codigo_municipio
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
