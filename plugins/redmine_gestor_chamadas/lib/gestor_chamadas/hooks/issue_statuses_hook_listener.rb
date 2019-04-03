# encoding: UTF-8
class IssueStatusesHookListener < Redmine::Hook::ViewListener

  render_on :view_issue_statuses_form, :partial => 'issue_statuses/is_archivable_form'

end
