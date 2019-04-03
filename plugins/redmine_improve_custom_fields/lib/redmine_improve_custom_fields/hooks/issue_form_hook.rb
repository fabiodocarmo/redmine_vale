module RedmineImproveCustomFields
  module Hooks
    class IssueFormHook < Redmine::Hook::ViewListener
      render_on :view_issues_form_details_bottom, partial: 'redmine_improve_custom_fields/improved_lists'
      render_on :view_issues_show_description_bottom, partial: 'redmine_improve_custom_fields/tracker_description'

      render_on :view_issues_sidebar_queries_bottom, partial: 'redmine_improve_custom_fields/issue_sidebar'

      render_on :view_issues_show_details_bottom, partial: 'redmine_improve_custom_fields/view_issues_show_details_bottom'
      render_on :view_issues_index_bottom, partial: 'redmine_improve_custom_fields/view_issues_index_bottom'

      def view_layouts_base_html_head(context = {})
        return stylesheet_link_tag('chosen.css', plugin: 'redmine_improve_custom_fields')
      end
    end
  end
end
