class SetPacSubjectJob < ExecJob
  unloadable

  def perform(issue)
    today_formatted = Time.now.strftime("%d/%m/%Y")
    tipo_pac = ""
    if (issue.custom_field_value(Setting.plugin_pac_consultoria_geral["tipo_pac"].to_i).include?("Novo Contrato"))
      tipo_pac = "Novo Contrato"
    else
      tipo_pac = "Aditivo"
    end

    razao_social = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["razao_social"].to_i)
    issue.subject = tipo_pac + " - " + razao_social + " - " + today_formatted
  rescue ArgumentError
  end
end
