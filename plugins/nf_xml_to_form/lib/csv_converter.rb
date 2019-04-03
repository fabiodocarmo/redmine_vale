require 'csv'
require 'nokogiri'

module CsvConverter
  
  def self.convert(csv_path, depara_path, xml_template_path)
    begin
      csv = CSV.read(csv_path, :encoding => 'windows-1252:utf-8', col_sep: ';')
    rescue Encoding::UndefinedConversionError
      csv = CSV.read(csv_path, :encoding => 'MacRoman:utf-8', col_sep: ';')
    end
    cols_indexes = csv.first.map.with_index.to_h
    depara = CSV.read(depara_path).map{|m| m.first.split(';')}.to_h
    xml_template = Nokogiri::XML(File.open(xml_template_path)).remove_namespaces!
    xmls = []
    entries = csv.length - 1
    raise CSV::MalformedCSVError if entries == 0

    (1..entries).each do |csv_row|
      if csv[csv_row][cols_indexes['CPF/CNPJ do Prestador']]
        xml = xml_template.clone
        depara.each do |xpath, col_name|
          if index = cols_indexes[col_name]
              value = csv[csv_row][index]
              if xpath == '//ValorServicos' and value.to_i == 0
                value = self.find_costs csv[csv_row][cols_indexes['Discriminação dos Serviços']]
              end
              xml.xpath(xpath).first.content = value
          end
        end
        xml.xpath('//Discriminacao').first.content = csv[csv_row].last
        xmls << xml
      end
    end
    XmlNormalizer.normalize(xmls)
    xmls
  end

  def self.find_costs string
    (string.scan(/(?:\d+.)*\d+,\d{2}/)
      .map{|i| i.gsub('.', '')}
      .map{|i| i.gsub(',','.')}
      .map &:to_f)
      .sum
  end
end
