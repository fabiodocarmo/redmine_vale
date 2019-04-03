module RedmineSla
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          before_save  :calc_due_date           , if: 'status_id_changed? || priority_id_changed? || project_id_changed? || tracker_id_changed?'

          after_create :create_new_status_report
          after_create  :notify_open_time
          after_create  :notify_overdue
          after_create :change_to_due_status

          after_update :update_status_report    , if: 'status_id_changed? || priority_id_changed? || project_id_changed? || tracker_id_changed?'
          after_update :create_new_status_report, if: 'status_id_changed? || priority_id_changed? || project_id_changed? || tracker_id_changed?'
          after_update  :notify_open_time    , if: '(status_id_changed? && status_was.try(:is_closed?) && !status.is_closed?) || priority_id_changed? || project_id_changed? || tracker_id_changed?'
          after_update  :notify_overdue      , if: 'status_id_changed? || priority_id_changed? || project_id_changed? || tracker_id_changed?'
          after_update  :change_to_due_status, if: 'status_id_changed? || priority_id_changed? || project_id_changed? || tracker_id_changed?'

          after_save  :notify_inactivity

          has_many :vsg_sla_sla_reports, class_name: 'VsgSla::SlaReport', dependent: :destroy

          alias_method_chain :css_classes, :sla
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def sla_overdue?(user=User.current, after_hours = 0.hour)
          due_date = visible_slas(user).map(&:custom_field).map { |cf| custom_field_value(cf) }.min

          if due_date.blank?
            false
          else
            (closed? ? closed_on : Time.zone.now + after_hours) > Time.parse(due_date)
          end
        end

        # 75% of working time gone
        def sla_almost_overdue?(user=User.current)
          visible_slas(user).each do |sla|
            if !sla.manual_date_select
              total_working_time = VsgSla::SlaReport.calc_total_working_time(sla, self)
              return true if sla.sla*0.75 <= total_working_time && sla.sla >= total_working_time
            end
          end

          false
        end

        def css_classes_with_sla(user=User.current)
          css_classes_without_sla(user) + if sla_overdue?(user)
            ' overdue-issue'
          elsif sla_almost_overdue?(user)
            ' almost-overdue-issue'
          else
            ''
          end
        end

        def calc_due_date
          VsgSla::Sla.issue_slas(self).each do |sla|
            next if sla.manual_date_select || !sla.custom_field

            if status_id_changed?
              next unless !status_was.in?(sla.issue_statuses) && status.in?(sla.issue_statuses)
            else
              next unless status.in?(sla.issue_statuses)
            end

            calculated_due_time = sla.calc_due_time(self)
            self.custom_field_values = {sla.custom_field_id => calculated_due_time}
          end
        end

        def notify_open_time
          VsgSla::Sla.issue_slas(self).each do |sla|
            next unless sla.notify_open_time_assign_to || sla.notify_open_time_author || sla.notify_open_time_group || (sla.notify_open_time_hour && sla.notify_open_time_hour > 0)

            NotifyOpenTimeJob.set(wait_until: sla.calc_date_plus_time(Time.zone.now, sla.notify_open_time_hour))
                               .perform_later(self.id, sla.notify_open_time_author, sla.notify_open_time_assign_to, sla.notify_open_time_group, sla.open_time_group_id, sla.id)
          end
        end

        def notify_inactivity
          VsgSla::Sla.issue_slas(self).each do |sla|
            next unless sla.notify_inactivity_assign_to || sla.notify_inactivity_author || sla.notify_inactivity_group || (sla.notify_inactivity_hour && sla.notify_inactivity_hour > 0)

            NotifyInactivityJob.set(wait_until: sla.calc_date_plus_time(Time.zone.now, sla.notify_inactivity_hour))
                               .perform_later(self.id, sla.notify_inactivity_author, sla.notify_inactivity_assign_to, sla.notify_inactivity_group, sla.inactivity_group_id, updated_on.to_s)
          end
        rescue NotImplementedError
        end

        def change_to_due_status
          VsgSla::Sla.issue_slas(self).each do |sla|
            next unless status.in?(sla.issue_statuses)
            next unless sla.change_status_after_due_time

            ChangeToDueStatusJob.set(wait_until: sla.calc_due_time(self, true)).perform_later(self.id, sla.id)
          end
        rescue NotImplementedError
        end

        def notify_overdue
          VsgSla::Sla.issue_slas(self).each do |sla|
            next unless sla.custom_field
            next unless !status_was.in?(sla.issue_statuses) && status.in?(sla.issue_statuses)
            next unless sla.notify_overdue_author || sla.notify_overdue_assign_to || sla.notify_overdue_group
            next unless due_time = sla.calc_due_time(self, true)

            NotifyOverdueJob.set(wait_until: due_time - (sla.notify_overdue_hour.try(:hour) || 0))
              .perform_later(self.id, sla.notify_overdue_hour, sla.notify_overdue_author, sla.notify_overdue_assign_to, sla.notify_overdue_group, sla.overdue_group_id)
          end
        rescue NotImplementedError
        end

        def update_status_report
          VsgSla::SlaReport.update_status_report(self, self.status_was)
        end

        def create_new_status_report
          VsgSla::Sla.issue_slas(self).each do |sla|
            journals.includes(:details).where(journal_details: {prop_key: 'status_id'}).references(:details).each_with_index do |journal, idx|
              journal.details.each do |detail|
                next if VsgSla::SlaReport.find_by_issue_and_sla(self, sla).where(issue_status_id: detail.old_value).first

                sla_report = VsgSla::SlaReport.create!({
                  issue_id: id,
                  sla_id: sla.id,
                  issue_status_id: detail.old_value,
                  start_time: idx > 0 ? journals[idx-1].created_on : created_on,
                  principal_id: journal.user_id,
                  discount_from_sla: sla.issue_status_ids.include?(detail.old_value.to_i),
                  due_time: VsgSla::SlaReport.calc_due_time(sla, self)
                })

                sla_report.end_time   = journal.created_on
                sla_report.total_time = (journal.created_on - (idx > 0 ? journals[idx-1].created_on : created_on))/3600
                sla_report.working_time = VsgSla::SlaReport.calc_working_time(self, sla_report)
                sla_report.save!
              end
            end

            VsgSla::SlaReport.create_using_issue_and_sla!(self, sla)
          end
        end

        def visible_slas(user)
          @visible_slas ||= issue_slas.select { |sla| sla.custom_field.visible_by?(project, user) && !custom_field_value(sla.custom_field).blank? }
        end

        def issue_slas
          Rails.cache.fetch("issue_slas/#{id}/#{updated_on}") do
            @slas ||= VsgSla::Sla.issue_slas(self).includes(:custom_field).to_a
          end
        end
      end
    end
  end
end
