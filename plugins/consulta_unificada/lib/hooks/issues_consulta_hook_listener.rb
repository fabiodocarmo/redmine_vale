class IssuesConsultaHookListenerHook < Redmine::Hook::ViewListener
  render_on :view_issues_show_description_bottom, :partial => 'issues/link_to_consultanf', :locals => {:issue => @issue}
  render_on :view_issues_form_details_bottom, :partial => 'public_tickets/validate_xml_nf'
end
