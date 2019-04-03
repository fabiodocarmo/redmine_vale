class ValidateTipoPacJob < ExecJob
  unloadable

  def perform(issue)
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Novo Contrato") && issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).length>1
      issue.errors.add :base, I18n.t('activerecord.messages.invalid_pac_type')
    end
  rescue ArgumentError
  end

end
