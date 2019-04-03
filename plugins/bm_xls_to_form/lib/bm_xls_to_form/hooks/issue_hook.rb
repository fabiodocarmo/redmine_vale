module BMXlsToForm
  module Hooks
    class IssueHook < Redmine::Hook::ViewListener
      render_on :view_issues_form_details_bottom, partial: 'bm_xls_to_form/issue_form_hook.html'
    end
  end
end
