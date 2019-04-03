class AutoForwardIssueToGrcJob < AutoForwardIssueJob

  def forward_issue
    status = Setting.plugin_nf_xml_to_form['auto_forward_job.status_grc'].to_i

    return false if status == 0

    @issue.status_id = status

    true
  end

end