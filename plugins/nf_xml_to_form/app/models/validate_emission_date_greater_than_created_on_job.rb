class ValidateEmissionDateGreaterThanCreatedOnJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue_id)

    emission_date_id = Setting.plugin_nf_xml_to_form['default_date_type'].to_sym

    emission_date_custom_field = issue.custom_value_for(Setting.plugin_nf_xml_to_form["data_emissao_field"])
    emission_date_value        = issue.custom_field_value(Setting.plugin_nf_xml_to_form["data_emissao_field"])

    if emission_date_custom_field.present? && emission_date_value.present?
      if Date.parse(emission_date_value) > issue.start_date
        issue.errors.add :base, I18n.t('activerecord.messages.less_than_created_on', field_name: emission_date_custom_field.custom_field.name)
      end
    end
  rescue ArgumentError
  end
end
