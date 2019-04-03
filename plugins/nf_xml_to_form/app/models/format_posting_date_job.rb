class FormatPostingDateJob < ExecJob
  unloadable

  def perform(issue)
    date_custom_field = Setting.plugin_nf_xml_to_form['campo_data_a_ser_formatado_antes_do_bpm']
    if issue.custom_field_value(date_custom_field).blank?
      issue.custom_field_values = { date_custom_field => Time.zone.now.strftime('%Y-%m-%d') }
    end
  end
end
