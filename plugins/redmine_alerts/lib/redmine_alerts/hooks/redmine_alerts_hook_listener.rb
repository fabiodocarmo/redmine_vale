class RedmineAlertsHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, partial: 'widgets/add_alerts.html'
end
