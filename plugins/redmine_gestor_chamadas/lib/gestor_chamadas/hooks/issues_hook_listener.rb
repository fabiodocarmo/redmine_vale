# encoding: UTF-8
class IssuesHookListener < Redmine::Hook::ViewListener

  def controller_issues_edit_before_save(context={ })
    issue = context[:issue]
    journal = issue.current_journal
    change_status  = issue.status_id_changed?
    controller = context[:controller]
    if change_status == true
    	if Setting.plugin_redmine_gestor_chamadas[:enable_satisfaction_survey] == "true" && Setting.plugin_redmine_gestor_chamadas[:answered_status].to_i == issue.status_id && IssueRelation.where(:issue_to_id => issue.id, :relation_type => "copied_to").blank?
        #url = controller.new_satisfaction_survey_url(issue.id, '0')
        url = Setting.plugin_redmine_gestor_chamadas[:url_satisfaction_survey] + issue.id
    		journal.notes+= "\n \n" + l(:answer_satisfaction_survey_message) + ": "+ url
    	end
  	end
  end

  def view_issues_show_description_bottom(context={ })
    context[:hook_caller].content_for :header_tags do
      stylesheet_link_tag('issues/redmine_gestor_chamadas', plugin: "redmine_gestor_chamadas")
    end

    context[:controller].render :partial => 'issues/show_satisfaction_survey_link'
  end
end
