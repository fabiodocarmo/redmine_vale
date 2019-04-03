class AssignToGestorContratoJob < ExecJob
  unloadable

  def perform(issue)
    if issue.custom_field_value(Setting.plugin_pac_consultoria_geral["gestor_contrato"]).to_i > 0
      issue.assigned_to_id = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["gestor_contrato"]).to_i
    end
  rescue ArgumentError
  end

end
