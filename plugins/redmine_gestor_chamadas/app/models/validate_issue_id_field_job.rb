class ValidateIssueIdFieldJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue_id)

    issue_id_field = Setting.plugin_redmine_gestor_chamadas["issue_id_field"]

    issue_id_custom_field = issue.custom_value_for(issue_id_field)
    issue_id_value        = issue.custom_field_value(issue_id_field)

    grid_hash = JSON.parse(issue_id_value.gsub('=>',':'))
    issues = grid_hash.values.map{|h| h.values.first}

    if issue_id_custom_field.present? && issue_id_value.present?
      issues.each do |issue_id|
        unless Issue.exists? issue_id.to_i
          issue.errors.add :base, I18n.t('not_a_valid_id', issue_id: issue_id)
        end
      end
    end
  rescue ArgumentError
  end
end
