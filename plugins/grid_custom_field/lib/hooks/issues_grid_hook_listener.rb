class IssuesGridHookListener < Redmine::Hook::ViewListener

	render_on :view_issues_form_details_top, :partial => 'issues/grid_custom_field'
	render_on :view_issues_show_description_bottom, :partial => 'issues/show_grid_custom_field'

end
