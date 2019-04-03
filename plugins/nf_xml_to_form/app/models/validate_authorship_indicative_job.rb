class ValidateAuthorshipIndicativeJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue_id)

    authorship_id = Setting.plugin_nf_xml_to_form['default_date_type'].to_sym

    authorship_custom_field = issue.custom_value_for(Setting.plugin_nf_xml_to_form["indicativo_autoria"])
    authorship_custom_value = issue.custom_field_value(Setting.plugin_nf_xml_to_form["indicativo_autoria"])

    deposit_custom_field = issue.custom_value_for(Setting.plugin_nf_xml_to_form["indicativo_deposito"])
    deposit_custom_value = issue.custom_field_value(Setting.plugin_nf_xml_to_form["indicativo_deposito"])

    if authorship_custom_field.present? && authorship_custom_value.present? && deposit_custom_field.present? && deposit_custom_value.present?
      if authorship_custom_value != "1 - Próprio contribuinte" && deposit_custom_value == "Sim"
        issue.errors.add :base, I18n.t('activerecord.messages.invalid_deposit_value', deposit_field_name: deposit_custom_field.custom_field.name, authorship_field_name: authorship_custom_field.custom_field.name)
      end
    end
  rescue ArgumentError
  end
end
