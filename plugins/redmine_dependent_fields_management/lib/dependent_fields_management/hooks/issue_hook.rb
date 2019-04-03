module DependentFieldsManagement
  module Hooks
    class IssueHook < Redmine::Hook::ViewListener
      render_on :view_issues_form_details_bottom, partial: 'dependent_fields/issue_form_hook.html'
    end
  end
end
