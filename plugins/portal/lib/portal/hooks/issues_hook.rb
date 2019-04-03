module Portal
  module Hooks
    class IssueHook < Redmine::Hook::ViewListener
      render_on :view_issues_index_bottom, partial: 'hooks/view_issues_index_bottom.html'
    end
  end
end
