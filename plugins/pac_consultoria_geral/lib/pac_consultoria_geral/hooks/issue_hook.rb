module PacConsultoriaGeral
  module Hooks
    class IssueHook < Redmine::Hook::ViewListener
      render_on :view_issues_form_details_bottom, partial: 'pac_consultoria_geral/issue_form_hook.html'
    end
  end
end
