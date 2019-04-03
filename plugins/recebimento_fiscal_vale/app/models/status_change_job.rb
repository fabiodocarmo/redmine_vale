class StatusChangeJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue)
    setting = Setting.plugin_recebimento_fiscal_vale['status_change']
    run_at = (Time.now + setting['days'].to_i.days).change({hour: setting['hour'], min: setting['minute']})
    AsyncStatusChange.set(wait_until: run_at).perform_later(issue.id)
  end
end
