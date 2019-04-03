class MailExportHook < Redmine::Hook::ViewListener

	render_on :view_issues_index_bottom, :partial => 'issues/export_to_email', :locals => { :issues => @issues, :project => @project, :query => @query }

end
