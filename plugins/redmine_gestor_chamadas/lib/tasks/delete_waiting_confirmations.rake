namespace :redmine do
  namespace :plugin do
    namespace :gestor_chamadas do
      task delete_waiting_confirmations: :environment do
        return true unless Setting.plugin_redmine_gestor_chamadas[:not_confirmed_status] && Setting.plugin_redmine_gestor_chamadas[:waiting_status] && Setting.plugin_redmine_gestor_chamadas[:after_days]

        deleting_issues = Issue.where(status_id: Setting.plugin_redmine_gestor_chamadas[:waiting_status])
          .where('(5 * (DATEDIFF(now(), created_on) DIV 7) + MID("0123444401233334012222340111123400012345001234550", 7 * WEEKDAY(created_on) + WEEKDAY (now()) + 1, 1) - 1 + (WEEKDAY(now()) in (5,6)) ) >= ?', Setting.plugin_redmine_gestor_chamadas[:after_days])

        if deleting_issues.blank?
          p "Nenhum chamado para ser arquivado"
        else
          p "Arquivando chamados #{deleting_issues.map(&:id).join(',')}"
        end

        deleting_issues.each do |issue|
          p "Arquivando chamado " + issue.id.to_s + " com status " + issue.status_id.to_s
          new_journal = Journal.new(:journalized => issue)
          new_journal.details << JournalDetail.new(:property => 'attr', :prop_key => 'status_id',:old_value => issue.status_id, :value => Setting.plugin_redmine_gestor_chamadas[:not_confirmed_status].to_i)
          issue.journals << new_journal
          issue.status_id = Setting.plugin_redmine_gestor_chamadas[:not_confirmed_status].to_i
          if issue.save(validate:false)
            p "Chamado arquivado para status " + issue.status_id.to_s
          else
            p "Ocorreu algum erro ao arquivar chamado."
          end
        end

#        Issue.where(status_id: Setting.plugin_redmine_gestor_chamadas[:waiting_status])
#          .where('(5 * (DATEDIFF(now(), created_on) DIV 7) + MID("0123444401233334012222340111123400012345001234550", 7 * WEEKDAY(created_on) + WEEKDAY (now()) + 1, 1) - 1 + (WEEKDAY(now()) in (5,6)) ) >= ?', Setting.plugin_redmine_gestor_chamadas[:after_days].to_i/2).each do |issue|
#          NotifyDeleteIssueMailer.delete_issue_notification(issue).deliver
#        end
      end
    end
  end
end
