class ExampleExecJob < ExecJob
  unloadable

  def perform(issue_id)
    i = Issue.find(issue_id)
    i.status_id = IssueStatus.where(is_closed: true).first.id
    i.save(validate: false)

    Rails.logger.info(i.inspect)
  end
end
