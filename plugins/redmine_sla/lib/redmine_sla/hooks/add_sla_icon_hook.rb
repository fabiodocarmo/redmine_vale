module RedmineSla
  module Hooks
    class AddSlaIconHook < Redmine::Hook::ViewListener
      render_on :view_issues_index_bottom, partial: 'add_sla_icon/add_sla_icon.html'
      render_on :view_my_page_bottom, partial: 'add_sla_icon/add_sla_icon.html'
    end
  end
end
