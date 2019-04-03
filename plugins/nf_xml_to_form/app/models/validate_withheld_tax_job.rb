class ValidateWithheldTaxJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue)
    validate_tax(issue)
  rescue ArgumentError
  end

  def validate_tax(issue)
    is_withheld_cf_id = Setting.plugin_nf_xml_to_form['withheld_tax_job.is_withheld_field']
    withheld_tax_cf_id = Setting.plugin_nf_xml_to_form['withheld_tax_job.withheld_tax_field']

    is_withheld_cf = CustomField.find(is_withheld_cf_id)
    withheld_tax_cf = CustomField.find(withheld_tax_cf_id)

    if issue.custom_field_value(is_withheld_cf_id) == '1' and issue.custom_field_value(withheld_tax_cf_id).to_f <= 0
      issue.errors.add :base, I18n.t('activerecord.messages.inconsistent_withheld_option_and_value',
                                     is_withheld_cf_name: is_withheld_cf.name,
                                     withheld_tax_cf_name: withheld_tax_cf.name)
    end
  end
end
