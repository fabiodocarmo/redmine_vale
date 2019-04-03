class ValidateVigenciaJob < ExecJob
  unloadable

  def perform(issue)
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Aditivo - Acréscimo de Prazo") || issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"]).include?("Novo Contrato")
      inicio_s = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["inicio_contrato"])
      fim_s = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["fim_contrato"])
      inicio_array = inicio_s.split("-")
      fim_array = fim_s.split("-")
      inicio = Date.new(inicio_array[0].to_i,inicio_array[1].to_i,inicio_array[2].to_i)
      fim = Date.new(fim_array[0].to_i,fim_array[1].to_i,fim_array[2].to_i)
      unless validate_vigencia_diff(inicio, fim)
        issue.errors.add :base, I18n.t('activerecord.messages.invalid_contract_validity')
      end
      if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["contencioso"]).to_i == 1
        unless validate_vigencia_contencioso(inicio,fim)
          issue.errors.add :base, I18n.t('activerecord.messages.invalid_contencioso_validity')
        end
      end
    end
  rescue ArgumentError
  end

  def validate_vigencia_diff(inicio, fim)
    fim > inicio
  end

  def validate_vigencia_contencioso(inicio, fim)
    inicio.day == fim.day && inicio.month == fim.month && inicio.year+10 == fim.year
  end
end
