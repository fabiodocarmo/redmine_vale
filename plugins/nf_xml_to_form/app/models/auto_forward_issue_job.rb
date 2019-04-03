class AutoForwardIssueJob < ExecJob

  def perform(issue)
    @issue = issue.is_a?(Issue) ? issue : Issue.find(issue)

    return false unless validate_xml_file_presence

    return false unless validate_cnpj_supplier

    #return false unless validate_tax_base_value_without_reduction('iss')
    #return false unless validate_tax_base_value_without_reduction('inss')

    return false unless validate_ranfs_requirement
    return false unless validate_daps_requirement

    return false unless validate_divergences

    if forward_issue
      @issue.send(:update_closed_on)
    end
  end

  def forward_issue
    false
  end

  private

  def validate_xml_file_presence
    nota_fiscal_xml_value = find_custom_field_value_from_settings('file_field')

    if nota_fiscal_xml_value.blank?
      return false
    end

    true
  end

  def validate_tax_base_value_without_reduction(tax_name)
    tax_base_value = find_custom_field_value_from_settings("servico_valores_valor_base_calculo_#{tax_name}_field").to_f
    service_value = find_custom_field_value_from_settings('servico_valores_valor_servicos_field').to_f
    tolerance = Setting.plugin_nf_xml_to_form['base_value_tolerance'].to_f

    tax_base_value.in?  (service_value - tolerance)..(service_value + tolerance)
  end

  def validate_ranfs_requirement
    RanfsBusinessRule.all.each do |br|
      return false if br.evaluate_rule(@issue)
    end

    true
  end

  def validate_daps_requirement
    DapsBusinessRule.all.each do |br|
      return false if br.evaluate_rule(@issue)
    end

    true
  end

  def validate_divergences
    divergences_custom_field_values = find_custom_field_value_from_settings('divergences_field')
    divergences_business_rules_values = DivergenceBusinessRule.all.map { |br| br.evaluate_rule(@issue) }

    (divergences_custom_field_values & divergences_business_rules_values).blank?
  end

  def find_custom_field_value_from_settings(settings_key)
    @issue.custom_field_value(Setting.plugin_nf_xml_to_form[settings_key])
  end

  def validate_cnpj_supplier
    find_custom_field_value_from_settings('prestador_cnpj') =~ /^\d{14}$/
  end  
end