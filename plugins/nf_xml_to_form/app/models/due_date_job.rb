class DueDateJob < ExecJob
  unloadable

  def perform(issue, retry_num=0)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue)

    due_date_data = DueDateResource.due_date(issue)

    if due_date_data.blank?
      due_date_data = { "days" => 0, "date_field" => Setting.plugin_nf_xml_to_form['default_date_type'].to_sym }
    end

    base_date_value = issue.custom_field_value(Setting.plugin_nf_xml_to_form["base_date_#{due_date_data['date_field']}_id"])

    issue.custom_field_values = {
      Setting.plugin_nf_xml_to_form["due_date"] =>
        (base_date_value.present? ? base_date_value.to_date : issue.created_on.to_date) +
          due_date_data["days"].to_i.days
    }
  end
end
