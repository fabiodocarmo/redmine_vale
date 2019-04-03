class RetentionJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue)

    order_type_cf_number = Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'field')
    zpr_retention_status_to_id = Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'zpr_status')
    reduced_base_status_to_id = Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'reduced_base_status')

    if zpr_retention_status_to_id and 
       issue.status_id_was.to_s != zpr_retention_status_to_id and 
       issue.custom_field_value(order_type_cf_number) == 'ZPR'

      issue.status_id = zpr_retention_status_to_id
    end

    if is_base_reduced? issue
      add_divergence issue
    end
  end

  def is_base_reduced? issue
  	total_value_cf_number = Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'total_value_cf_id')
  	iss_base_cf_number = Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'iss_base_value_cf_id')
  	inss_base_cf_number = Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'inss_base_value_cf_id')

    total_value = issue.custom_field_value(total_value_cf_number)
  	inss_base_value = issue.custom_field_value(inss_base_cf_number)
  	iss_base_value = issue.custom_field_value(iss_base_cf_number)

    return false if inss_base_value.blank? and iss_base_value.blank?

  	total_value = format_number_separator(total_value).to_f
  	inss_base_value = format_number_separator(inss_base_value).to_f
  	iss_base_value = format_number_separator(iss_base_value).to_f

    inss_base_value < (total_value - 1) or iss_base_value < (total_value - 1)

  end

  def add_divergence issue
    divergences_cf_id = Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'cf_divergences')
    divergences = issue.custom_field_value(divergences_cf_id)
    divergences_keys = Setting.plugin_recebimento_fiscal_vale['order_type'].try('[]', 'divergences')

    if divergences_cf_id.present? and divergences.present?
      issue.custom_field_values = {divergences_cf_id => (divergences += divergences_keys).uniq}
    end
  end

  def format_number_separator(value)
      return value unless value.is_a? String
      value.gsub(/\.(?=.*,)/, '').gsub(/,(?=.*\.)/, '').tr(',', '.')
  end

end