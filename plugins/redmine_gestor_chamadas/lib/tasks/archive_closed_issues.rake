# encoding: UTF-8

namespace :redmine do
  namespace :plugins do
    namespace :gestor_chamados_vale do
      task archive_closed_issues: :environment do

        return if Setting.plugin_redmine_gestor_chamadas[:enable_archive_issue] == "false"

        archive_after_days = Setting.plugin_redmine_gestor_chamadas[:archive_after_days].to_i
        archived_status_id = Setting.plugin_redmine_gestor_chamadas[:archived_status].to_i
        archivable_statuses = IssueStatus.where(is_closed: true, archivable: true)
                                  .where('id <> ?', archived_status_id).pluck(:id)
        open_statuses = IssueStatus.where(is_closed:false)
                                  .where('id <> ?', archived_status_id).pluck(:id)
        send_survey_after_days = Setting.plugin_redmine_gestor_chamadas[:mail_satisfaction_survey_after_days].to_i
        reference_date = Date.today() - 1.day

        Issue.where(status_id: archivable_statuses).order(:closed_on).find_each(batch_size: 50) do |issue|
          # Data da ultima vez que o ticket foi fechado
          last_closed_journal = Journal.includes(:details)
                                    .where(journalized_id: issue.id)
                                    .where(journal_details: {
                                        prop_key: 'status_id',
                                        old_value: open_statuses,
                                        value: archivable_statuses
                                    }).order(:created_on).last

          if last_closed_journal.blank?
            next
          end

          journal_closed_date = last_closed_journal.created_on.to_date
          working_days_since_last_change = journal_closed_date.business_days_until(reference_date)

          # Envio de lembrete de pesquisa de satisfação
          if Setting.plugin_redmine_gestor_chamadas[:enable_satisfaction_survey] == "true"
            if issue.status_id == Setting.plugin_redmine_gestor_chamadas[:answered_status].to_i
              if working_days_since_last_change == (archive_after_days - send_survey_after_days) &&
                  send_survey_after_days != 0
                NotifySatisfactionSurveyMailer.satisfaction_survey_notification(issue).deliver
                print 'Issue ' ,issue.id, ' foi fechada. Enviando pesquisa' ,"\n"
              end
            end
          end

          if working_days_since_last_change >= archive_after_days
            if Setting.plugin_redmine_gestor_chamadas[:archive_with_comments_after_closed] == "true" or
                issue.journals_after(last_closed_journal.id).size == 0
              issue.journals.build
              journal = issue.journals.last
              journal.user_id = User.find(12379).id
              issue.status_id = archived_status_id
              issue.save!(validate: false)

              if Setting.plugin_redmine_gestor_chamadas[:enable_satisfaction_survey] == "true"
                satisfaction_survey = SatisfactionSurvey.new(issue: issue)
                if ! satisfaction_survey.save
                  print 'Erro ao criar pesquisa de satifação vazia'
                end
              end

              print 'Issue ', issue.id, ' arquivada, fechada ha mais de ', archive_after_days,' dias, em ', last_closed_journal.created_on , '.',"\n"
            end
          end
        end

        puts 'Fim do arquivamento'

      end
    end
  end
end
