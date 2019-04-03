class AssignToConsultorGeralJob < ExecJob
  unloadable

  def perform(issue)
    # Se o Gerente/Diretor aprovar, atribuir o chamado ao Consultor Geral
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["aprovacao_gerente"]).to_i == 1
      if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["consultor_geral"]).to_i > 0
        issue.assigned_to_id = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["consultor_geral"]).to_i
      end
    end
  rescue ArgumentError
  end

end
