class AssignToGerenteJob < ExecJob
  unloadable

  def perform(issue)
    # Se o Gestor do Contrato aprovar, atribuir o chamado ao Gerente/Diretor
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["aprovacao_gestor"]).to_i == 1
      if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["gerente_diretor"]).to_i > 0
        issue.assigned_to_id = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["gerente_diretor"]).to_i
      end
    end
  rescue ArgumentError
  end

end
