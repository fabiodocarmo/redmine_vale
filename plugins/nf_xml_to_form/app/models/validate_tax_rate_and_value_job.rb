class ValidateTaxRateAndValueJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue_id)
    
    if issue.custom_field_value(Setting.plugin_nf_xml_to_form['withheld_tax_job.is_withheld_field']) == '1'
      issue = validate_tax(issue, 'iss')
    end
    issue = validate_tax(issue, 'inss')
    issue = validate_tax(issue, 'pis')
    issue = validate_tax(issue, 'cofins')
    issue = validate_tax(issue, 'csll')
    issue = validate_tax(issue, 'ir')
    issue = validate_tax(issue, 'icms')

  rescue ArgumentError
  end

  def validate_tax(issue, tax)

    tax_rate_id = Setting.plugin_nf_xml_to_form["servico_valores_valor_aliquota_#{tax}_field"]
    value_id    = Setting.plugin_nf_xml_to_form["servico_valores_valor_valor_#{tax}"]

    tax_rate_custom_field = issue.custom_value_for(tax_rate_id)
    tax_rate_custom_value = issue.custom_field_value(tax_rate_id)

    tax_value_custom_field = issue.custom_value_for(value_id)
    tax_value_custom_value = issue.custom_field_value(value_id)

    if tax_value_custom_value.present? && tax_rate_custom_value.present?
      if tax_rate_custom_value.to_f == 0 && tax_value_custom_value.to_f > 0
        issue.errors.add :base, I18n.t('activerecord.messages.tax_rate_equals_zero', rate_field_name: tax_rate_custom_field.custom_field.name, value_field_name: tax_value_custom_field.custom_field.name)
      elsif tax_rate_custom_value.to_f > 0 && tax_value_custom_value.to_f == 0
        issue.errors.add :base, I18n.t('activerecord.messages.tax_value_equals_zero', rate_field_name: tax_rate_custom_field.custom_field.name, value_field_name: tax_value_custom_field.custom_field.name)
      end
    end

    issue
  end
end
