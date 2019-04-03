class SetConsultorGeralJob < ExecJob
  unloadable

  def perform(issue)
    group = Group.where(lastname: 'Consultoria Geral - Consultor Geral').first
    user = User.in_group(group).first
    issue.assigned_to_id = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["consultor_geral"]).to_i
    issue.custom_field_values = {
      Setting.plugin_pac_consultoria_geral["consultor_geral"].to_i => user.id
    }
  rescue ArgumentError
  end

end
