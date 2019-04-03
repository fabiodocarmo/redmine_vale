require_relative './test_helper'

class XmlConverterTest < ActiveSupport::TestCase
  test "converter" do
    Dir.entries(File.join(File.dirname(__FILE__), 'xmls', 'input')).sort.each do |entry|
      next if entry.in?(['.', '..'])

      input  = File.read(File.join(File.dirname(__FILE__), 'xmls', 'input', entry))
      output = File.read(File.join(File.dirname(__FILE__), 'xmls', 'output', entry))

      p "converter Iniciando #{entry}"
      assert_equal Nokogiri::XML(output, nil, 'UTF-8').to_xhtml(indent:3, indent_text: " "),
                   Nokogiri::XML(XmlConverter.convert(input), nil, 'UTF-8').to_xhtml(indent:3, indent_text: " ")
      p "converter #{entry} passou com sucesso"
    end
  end

  test "required_fields" do
    Dir.entries(File.join(File.dirname(__FILE__), 'xmls', 'input')).sort.each do |entry|
      next if entry.in?(['.', '..'])

      output = File.read(File.join(File.dirname(__FILE__), 'xmls', 'output', entry))
      output = Nokogiri::XML(output, nil, 'UTF-8').remove_namespaces!

      p "required_fields Iniciando #{entry}"

      refute_empty output.xpath("//InfNfse/Numero").text
      refute_empty output.xpath("//InfNfse/DataEmissao").text
      refute_empty output.xpath("//Servico//ValorServicos").text
      refute_empty output.xpath("//Servico//ItemListaServico").text
      refute_empty output.xpath("//TomadorServico//Cnpj").text
      refute_empty output.xpath("//Servico//CodigoMunicipio").text
      refute_empty output.xpath("//OrgaoGerador//CodigoMunicipio").text

      p "required_fields #{entry} passou com sucesso"
    end
  end

  test "field_formatting" do
    # Testa a formatação do Número do Documento Fiscal apenas com dígitos ex.: /^\d*$/

    p "field_formatting iniciando"

    xml = '<?xml version="1.0" encoding="UTF-8" ?>
            <Field Name="ForNumNota3" FieldName="{@ForNumNota}">
            <FormattedValue>1.8\n oasjdfji85$%*(   ~^ // #@</FormattedValue>
            <Value>1885.00</Value>
            </Field>'
    xml = Nokogiri::XML(xml)
    xpath = '//Field[@Name="ForNumNota3"]/FormattedValue'
    assert_equal '<Numero>1885</Numero>', XmlConverter.build_tag_numero_nfse(xml, xpath), 'Número NFSe'

    p "field_formatting passou com sucesso"
  end
end
