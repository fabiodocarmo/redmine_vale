module NfXmlToForm
  module Hooks
    class IssueHook < Redmine::Hook::ViewListener
      render_on :view_issues_form_details_bottom, partial: 'nf_xml_to_form/issue_form_hook.html'
    end
  end
end
