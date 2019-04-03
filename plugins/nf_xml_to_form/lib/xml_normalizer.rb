module XmlNormalizer

  def self.normalize(xmls)
    xmls.each.with_index do |xml, index|
      normalize_optante_simples(xml)
      normalize_cod_ibge_gerador(xml)
      normalize_cod_municipio_prestador(xml)
    end
  end

  def self.normalize_optante_simples(xml)
    if xml.xpath('//OptanteSimplesNacional').first.content == '0'
      xml.xpath('//OptanteSimplesNacional').first.content = '2'
    end
  end

  def self.normalize_cod_ibge_gerador(xml)
    xml.xpath('//OrgaoGerador/CodigoMunicipio').first.content = '3550308'
    xml.xpath('//OrgaoGerador/Uf').first.content = 'SP'
  end

  def self.normalize_cod_municipio_prestador(xml)
    xml.xpath('//PrestadorServico/Endereco/CodigoMunicipio').first.content = '3550308'
  end
end
