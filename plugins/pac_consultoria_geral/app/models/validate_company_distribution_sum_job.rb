class ValidateCompanyDistributionSumJob < ExecJob
  unloadable

  def perform(issue)
    if (issue.custom_field_value(Setting.plugin_pac_consultoria_geral["prestrado_entre_grupo"]).to_i==1)
      distribuicao = issue.custom_field_value(Setting.plugin_pac_consultoria_geral["distribuicao"])
      json = JSON.parse(distribuicao.gsub("=>",":"))
      soma = json.map{|k, v| v[Setting.plugin_pac_consultoria_geral["valor_distribuido"].to_s].to_f.round(2)}.sum.round(2)
      if soma != 100.00
        issue.errors.add :base, I18n.t('activerecord.messages.invalid_company_distribution_sum')
      end
    end
  rescue ArgumentError
  end
end
