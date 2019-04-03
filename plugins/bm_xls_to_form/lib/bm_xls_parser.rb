module BmXlsParser

  def self.get_file_extension(file_path)
    #Verifico se é xlsx
    begin   #try
      Roo::Spreadsheet.open(file_path, extension: :xlsx)
      return 'xlsx'
    rescue  #catch
    end

    #Verifico se é xls
    begin   #try
      Roo::Spreadsheet.open(file_path, extension: :xls)
      return 'xls'
    rescue  #catch
    end

    return ''

  end

  def self.convert_to_float_str(value)
    fmt = value
    fmt.round(3)
    fmt = sprintf('%.3f', fmt)
    fmt.gsub! '.', ','
  end

end