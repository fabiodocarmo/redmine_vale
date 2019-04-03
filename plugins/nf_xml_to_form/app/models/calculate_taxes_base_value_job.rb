class CalculateTaxesBaseValueJob < ExecJob
  unloadable

  def perform(issue)
    calculate_tax_base_value(issue, 'inss')
    calculate_tax_base_value(issue, 'iss')
    calculate_tax_base_value(issue, 'icms')
  end

  private

  def calculate_tax_base_value(issue, tax_name)
    tax_base_value_field = find_custom_fields_from_settings(issue, "servico_valores_valor_base_calculo_#{tax_name}_field")
    service_value_field = find_custom_fields_from_settings(issue, 'servico_valores_valor_servicos_field')
    tax_rate_field = find_custom_fields_from_settings(issue, "servico_valores_valor_aliquota_#{tax_name}_field")
    tax_value_field = find_custom_fields_from_settings(issue, "servico_valores_valor_valor_#{tax_name}")

    return unless service_value_field && tax_rate_field && tax_value_field && tax_base_value_field

    service_value = issue.custom_field_value(service_value_field)
    tax_rate = issue.custom_field_value(tax_rate_field)
    tax_value = issue.custom_field_value(tax_value_field)

    tax_base_value = do_calculate_tax_base_value(tax_rate, tax_value, service_value)
    tax_base_value_f, service_value_f = tax_base_value.to_f, service_value.to_f

    if ((service_value_f - 1.0) < tax_base_value_f) && (tax_base_value_f < (service_value_f + 1.0))
      tax_base_value = service_value
    end

    issue.custom_field_values = { tax_base_value_field.id => format_tax_base_value(tax_base_value) }

    if tax_base_value_f > (service_value_f + 1.0)
      issue.errors.add :base, I18n.t(
          'activerecord.messages.tax_base_value_greater_than_service_value',
          tax_base_value_field_name: tax_base_value_field.name,
          service_value_field_name: service_value_field.name,
          tax_rate_field_name: tax_rate_field.name,
          tax_value_field_name: tax_value_field.name
      )
    end
  end

  def find_custom_fields_from_settings(issue, settings_key)
    issue.custom_value_for(Setting.plugin_nf_xml_to_form[settings_key]).try(:custom_field)
  end

  def do_calculate_tax_base_value(tax_rate, tax_value, service_value)
    return nil if tax_rate.blank? || tax_value.blank?

    tax_rate_f = tax_rate.to_f
    tax_value_f = tax_value.to_f
    if (tax_rate_f > 0 && tax_value_f > 0)
      tax_value_f / (tax_rate_f / 100.0)
    else
      service_value
    end
  end

  def format_tax_base_value(tax_base_value)
    return tax_base_value if tax_base_value.blank?

    precision = 2
    "%.#{precision}f" % tax_base_value.to_f.round(precision)
  end

end
