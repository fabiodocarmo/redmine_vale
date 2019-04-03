class ValidateMetodoContratacaoJob < ExecJob
  unloadable

  def perform(issue)
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["metodo_contratacao"]).include?("Direta") && issue.custom_field_value(Setting.plugin_pac_consultoria_geral["metodo_contratacao"]).include?("Concorrencial")
      issue.errors.add :base, I18n.t('activerecord.messages.invalid_metodo_contratacao')
    end
  rescue ArgumentError
  end

end
