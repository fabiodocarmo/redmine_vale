desc "Explaining what the task does"
task :move_xmls do
  xml_folder = '/home/victor.campos/Downloads/Xmls'
  Dir.entries(xml_folder).select { |entry| !File.directory?(File.join(xml_folder, entry)) }.each_with_index do |entry, index|
    next if entry.in?(['.', '..'])

    xml_file_path = File.join(xml_folder, entry)
    xml = Nokogiri::XML(File.read(xml_file_path)).remove_namespaces!

    codigo_municipio = XmlConverter.value(xml, '//OrgaoGerador/CodigoMunicipio', '//orgao_gerador/codigo_municipio',
                                               '//TimbrePrefeituraLinha1', '//GovDigital//prestador//municipio', '//tcInfTmd/tsMunTmd',
                                               '//cMunFG', '//DadosPrestador/Endereco/CodigoMunicipio', '//cidadePrestador',
                                               '//DadosPrestador//municipio', '//EnderecoPrestador/Cidade',
                                               '//PrestadorServico/Endereco/CodigoMunicipio', '//PRE_ENDERECO_ES_MUNICIPIO',
                                               '//prestador/endereco/codigoMunipio', '//CidadePrestador')

    if codigo_municipio
      directory_name = File.join(xml_folder, codigo_municipio)
      Dir.mkdir(directory_name) unless File.exists?(directory_name)

      FileUtils.mv(xml_file_path, directory_name)
      p index
    end
  end
end

task :xml_converter do
  xml_folder = '/home/victor.campos/Downloads/Xmls'
  xml_tratados_folder = '/home/victor.campos/Downloads/Xmls/XmlsTratados'

  CSV.read(File.join(xml_folder, 'list.csv'), col_sep: ";") do |row|
    next if row[3].to_i == 1

    Dir.entries(xml_folder).select { |entry| entry == row[0] }.each_with_index do |entry, index|
      p entry

      xml_name = Dir.entries(File.join(xml_folder, entry))
         .select { |entry| !File.directory?(File.join(xml_folder, entry)) }
         .select { |entry| !entry.in?(['.', '..']) }.first

      return unless xml_name

      xml_file_path = File.join(xml_folder, entry, xml_name)

      input  = File.read(xml_file_path)
      File.open(File.join(xml_tratados_folder, "#{entry}_#{xml_name}"), "w") {|f| f.write(Nokogiri::XML(input).to_xhtml(indent:3, indent_text: " ")) }

      output = Nokogiri::XML(XmlConverter.convert(input)).to_xhtml(indent:3, indent_text: " ")
      File.open(File.join(xml_tratados_folder, "#{entry}_#{xml_name}.output"), "w") {|f| f.write(output) }
    end
  end
end

desc "Reorganizar notas output"
task :reorganizar do
  def get_city_name(entry)
    p "#{entry}"
    a = Mechanize.new
    a.set_proxy 'localhost', 3128
    a.get("http://cidades.ibge.gov.br/xtras/perfil.php?codmun=#{entry}").search(".municipio.titulo").text
  end

  xml_folder = '/home/victor.campos/Workspaces/Redmine/xml_converter/test/xmls/output'
  Dir.entries(xml_folder).select { |entry| !File.directory?(File.join(xml_folder, entry)) }.each_with_index do |entry, index|
    next if entry.in?(['.', '..'])

    xml_file_path = File.join(xml_folder, entry)
    xml = Nokogiri::XML(File.read(xml_file_path)).remove_namespaces!

    codigo_municipio = XmlConverter.value(xml, '//OrgaoGerador/CodigoMunicipio')

    if codigo_municipio
      directory_name = File.join(xml_folder, 'reorganizar', get_city_name(codigo_municipio))
      Dir.mkdir(directory_name) unless File.exists?(directory_name)

      FileUtils.cp(xml_file_path, directory_name)
      p index
    end
  end

  Dir.entries(File.join(xml_folder, "reorganizar")).select { |entry| File.directory?(File.join(xml_folder, "reorganizar", entry)) }.each_with_index do |entry, index|
    next if entry.in?(['.', '..'])
    entries = Dir.entries(File.join(xml_folder, "reorganizar", entry)).select { |entry| !entry.in?(['.', '..']) }
    if entries.count == 1
      FileUtils.mv(File.join(xml_folder, "reorganizar", entry, entries.first), "#{xml_folder}_2")
      FileUtils.rmdir(File.join(xml_folder, "reorganizar", entry))

      p index
    end
  end
end

task :clear_input do
  xml_folder = '/home/victor.campos/Workspaces/Redmine/xml_converter/test/xmls/'
  Dir.entries(File.join(xml_folder, 'output')).select { |entry| !File.directory?(File.join(xml_folder, 'output', entry)) }.each_with_index do |entry, index|
    next if entry.in?(['.', '..'])

    begin
      output = File.read(File.join(xml_folder, 'output', entry))
    rescue
      FileUtils.rm(File.join(xml_folder, 'input', entry))
      p "removing #{entry}"
    end
  end
end

task :real_xml_converter do
  xml_folder = '/home/victor.campos/Workspaces/Redmine/xml_converter/convert'
  xml_tratados_folder = '/home/victor.campos/Workspaces/Redmine/xml_converter/tratadas'

  Dir.entries(xml_folder).select { |entry| !File.directory?(File.join(xml_folder, entry)) }.each_with_index do |entry, index|
    p entry

    xml_file_path = File.join(xml_folder, entry)

    input  = File.read(xml_file_path)
    output = Nokogiri::XML(XmlConverter.convert(input)).to_xhtml(indent:3, indent_text: " ")
    File.open(File.join(xml_tratados_folder, "#{entry}"), "w") {|f| f.write(output) }
  end
end
