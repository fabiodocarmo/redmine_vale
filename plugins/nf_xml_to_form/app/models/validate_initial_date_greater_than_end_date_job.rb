class ValidateInitialDateGreaterThanEndDateJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue_id)

    initial_date_id = Setting.plugin_nf_xml_to_form['default_date_type'].to_sym

    initial_date_custom_field = issue.custom_value_for(Setting.plugin_nf_xml_to_form["data_inicio_validade"])
    initial_date_value        = issue.custom_field_value(Setting.plugin_nf_xml_to_form["data_inicio_validade"])

    end_date_custom_field = issue.custom_value_for(Setting.plugin_nf_xml_to_form["data_termino_validade"])
    end_date_value        = issue.custom_field_value(Setting.plugin_nf_xml_to_form["data_termino_validade"])

    if initial_date_custom_field.present? && initial_date_value.present? && end_date_custom_field.present? && end_date_value.present?
      if Date.parse(initial_date_value) > Date.parse(end_date_value)
        issue.errors.add :base, I18n.t('activerecord.messages.less_than_end_date', field_name: initial_date_custom_field.custom_field.name, target_field_name: end_date_custom_field.custom_field.name)
      end
    end
  rescue ArgumentError
  end
end
