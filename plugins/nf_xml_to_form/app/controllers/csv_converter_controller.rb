class CsvConverterController < ApplicationController

  before_filter :find_project_by_project_id, :authorize

  class NoFileUploadedError < StandardError
  end

  def index
  end

  def convert

    begin
      raise NoFileUploadedError unless params[:csv_filename]
      depara_path = File.join(Rails.root, 'plugins', 'nf_xml_to_form', 'lib', 'de_para_tag_coluna.csv')
      xml_template_path = File.join(Rails.root, 'plugins', 'nf_xml_to_form', 'lib', 'bh_model.xml')
      xml_array = CsvConverter.convert(params[:csv_filename].path, depara_path, xml_template_path)

      stringio = Zip::OutputStream.write_buffer do |zio|
        xml_array.each.with_index do |x, i|
          zio.put_next_entry("nota_#{i+1}_#{Time.now.strftime('%Y%m%d%H%M%S%L')}.xml")
          zio.write(x.to_xml)
        end
      end
      stringio.rewind

      zip_file = stringio.sysread
      send_data zip_file, filename: 'notas_fiscais_convertidas.zip'
    rescue => exception
      if exception.is_a? NoFileUploadedError
        flash[:error] = l(:csv_converter_no_file)
      elsif exception.is_a? NoMethodError
        flash[:error] = l(:csv_converter_error_reading_file)
      elsif exception.is_a? Encoding::UndefinedConversionError
        flash[:error] = l(:csv_converter_invalid_file)
      elsif exception.is_a? CSV::MalformedCSVError
        flash[:error] = l(:csv_converter_error_reading_file)
      else
        flash[:error] = l(:csv_converter_error_message)
      end

      redirect_to action: :index, project_id: params[:project_id]
    end
  end
end
