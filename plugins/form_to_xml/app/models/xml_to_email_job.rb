class XmlToEmailJob < ExecJob
  unloadable

  def perform(issue_id)
    issue = issue.is_a?(Issue) ? issue.reload : Issue.find(issue_id)
    Rails.logger.info(issue.inspect)

    custom_value = issue.custom_values.find_by_custom_field_id(Setting.plugin_form_to_xml["file_field"])
    RedmineXmlToEmailMailer.notify_external(issue, Attachment.find(custom_value.value)).deliver
  end
end
