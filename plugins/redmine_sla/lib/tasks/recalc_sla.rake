# encoding: UTF-8

namespace :redmine do
  namespace :plugins do
    namespace :redmine_sla do
      task :recalc_sla, [:sla_id] => [:environment] do |t, args|
        return '' unless sla_id = args[:sla_id]
        sla = VsgSla::Sla.find(sla_id)

        issues = Issue.open

        unless sla.all_projects
          issues = issues.where(project_id: sla.project_ids)
        end

        unless sla.all_trackers
          issues = issues.where(tracker_id: sla.tracker_ids)
        end

        unless sla.all_enumerations
          issues = issues.where(priority_id: sla.enumeration_ids)
        end

        issues.includes(journals: [:details]).find_each do |issue|
          p "# Inicio - #{issue.id}"
          VsgSla::SlaReport.where(sla_id: sla.id, issue_id: issue.id).destroy_all
          first = true
          issue.journals.each do |journal|
            journal.details.each_with_index do |detail|
              next unless detail.prop_key == 'status_id'

              if first
                first = false

                p "# Update old value sla report - Inicio - #{detail.id}"
                sla_report = VsgSla::SlaReport.create!({
                  issue_id: issue.id,
                  sla_id: sla.id,
                  issue_status_id: detail.old_value,
                  start_time: issue.created_on,
                  principal_id: journal.user_id,
                  discount_from_sla: sla.issue_status_ids.include?(detail.old_value.to_i),
                  due_time: VsgSla::SlaReport.calc_due_time(sla, issue)
                })

                sla_report.end_time   = journal.created_on
                sla_report.total_time = (journal.created_on - issue.created_on)/3600
                sla_report.working_time = VsgSla::SlaReport.calc_working_time(issue, sla_report)
                sla_report.save!
                p "# Update old value sla report - Fim - #{detail.id}"
              else
                if detail.old_value
                  p "# Update old value sla report - Inicio - #{detail.id}"
                  VsgSla::SlaReport.uncalc_sla_report(issue, IssueStatus.find(detail.old_value)).each do |sla_report|
                    sla_report.end_time   = journal.created_on
                    sla_report.total_time = (journal.created_on - sla_report.start_time)/3600
                    sla_report.working_time = VsgSla::SlaReport.calc_working_time(issue, sla_report)
                    sla_report.save!
                  end
                  p "# Update old value sla report - Fim - #{detail.id}"
                end
              end

              # Create new
              p "# Create sla report - Inicio - #{detail.id}"
              VsgSla::SlaReport.create!({
                issue_id: issue.id,
                sla_id: sla.id,
                issue_status_id: detail.value,
                start_time: journal.created_on,
                principal_id: journal.user_id,
                discount_from_sla: sla.issue_status_ids.include?(detail.value.to_i),
                due_time: VsgSla::SlaReport.calc_due_time(sla, issue)
              })
              p "# Create sla report - Fim - #{detail.id}"
            end
          end

          if VsgSla::SlaReport.where(sla_id: sla.id, issue_id: issue.id).count == 0
            p "# Create sla report - Inicio - Novo"
            sla_report = VsgSla::SlaReport.create!({
              issue_id: issue.id,
              sla_id: sla.id,
              issue_status_id: issue.status_id,
              start_time: issue.created_on,
              principal_id: issue.assigned_to_id,
              discount_from_sla: sla.issue_status_ids.include?(issue.status_id),
              due_time: VsgSla::SlaReport.calc_due_time(sla, issue)
            })
            p "# Create sla report - Fim - Novo"
          end

          if sla.custom_field
            p "# Inicio Calc Due Time"
            calculated_due_time = sla.calc_due_time(issue)
            issue.custom_field_values = {sla.custom_field_id => calculated_due_time}

            issue.save(validate: false)
            p "# Fim Calc Due Time"
          end
          p "# Fim - #{issue.id}"
        end
      end
    end
  end
end
