class VsgSla::Sla < VsgSla
  unloadable

  attr_protected :sla, :project_ids, :tracker_ids, :issue_statuses_ids, :enumeration_ids, :user_ids,
                 :sla_office_hour_id     , :custom_field_id,
                 :notify_overdue_hour    , :notify_overdue_author, :notify_overdue_assign_to,
                 :notify_overdue_group   , :overdue_group_id,
                 :notify_inactivity_hour , :notify_inactivity_author, :notify_inactivity_assign_to,
                 :notify_inactivity_group, :inactivity_group_id,
                 :notify_open_time_hour  , :notify_open_time_author, :notify_open_time_assign_to,
                 :notify_open_time_group , :inactivity_group_id,
                 :all_projects, :all_trackers, :all_enumerations, :all_groups,
                 :change_status_after_due_time, :due_status_id, as: :admin

  scope :issue_slas, -> (issue) do
    joins("LEFT JOIN projects_vsg_sla_slas ON projects_vsg_sla_slas.sla_id = vsg_sla_slas.id")
     .joins("LEFT JOIN trackers_vsg_sla_slas ON trackers_vsg_sla_slas.sla_id = vsg_sla_slas.id")
     .joins("LEFT JOIN enumerations_vsg_sla_slas ON enumerations_vsg_sla_slas.sla_id = vsg_sla_slas.id")
     .joins("LEFT JOIN users_vsg_sla_slas ON users_vsg_sla_slas.sla_id = vsg_sla_slas.id")
     .joins("LEFT JOIN groups_users gu ON gu.group_id = users_vsg_sla_slas.group_id")
     .includes(:issue_statuses)
     .where('projects_vsg_sla_slas.project_id = ? or all_projects = true'    , issue.project_id)
     .where('trackers_vsg_sla_slas.tracker_id = ? or all_trackers = true'    , issue.tracker_id)
     .where('enumerations_vsg_sla_slas.enumeration_id = ? or all_enumerations = true', issue.priority_id)
     .where('gu.group_id = ? or gu.user_id = ? or all_groups = true', issue.assigned_to_id, issue.assigned_to_id)
     .where(use_custom_field_where(issue)).uniq
  end

  belongs_to :office_hour
  delegate :timezone, to: :office_hour, prefix: false

  belongs_to :custom_field

  belongs_to :overdue_group   , class_name: 'Group'
  belongs_to :inactivity_group, class_name: 'Group'
  belongs_to :open_time_group , class_name: 'Group'

  belongs_to :due_status, class_name: 'IssueStatus'

  has_many :sla_reports, dependent: :destroy

  has_and_belongs_to_many :projects
  has_and_belongs_to_many :trackers
  has_and_belongs_to_many :enumerations
  has_and_belongs_to_many :issue_statuses
  has_and_belongs_to_many :users, class_name: 'Group'

  def calc_due_time(issue, cached=false)
    if cached && custom_field && (wait_until = issue.custom_field_value(custom_field)) && !wait_until.blank?
      Time.parse(wait_until)
    else
      SlaReport.calc_due_time(self, issue)
    end
  end

  def working_days
    @working_days ||= office_hour.working_days.order(:start_time)
  end

  def calc_date_plus_time(start_time, time)
    start_time_with_wd_zone = TimeUtils.time_with_zone(timezone, start_time)

    while time > 0
      working_days.select { |wd| wd.week_day.to_s == WorkingDay::WEEK_DAY[start_time_with_wd_zone.wday].to_s }.each do |wd|
        next if TimeUtils.compare_times(wd.end_time, start_time_with_wd_zone) == -1

        if TimeUtils.compare_times(start_time_with_wd_zone, wd.start_time) == -1
          start_time_with_wd_zone += TimeUtils.diff(wd.start_time, start_time_with_wd_zone).hour
        end

        diff = [TimeUtils.diff(wd.end_time, start_time_with_wd_zone), time].min

        time -= diff
        start_time_with_wd_zone += diff.hour
      end

      start_time_with_wd_zone = (start_time_with_wd_zone + 1.day).beginning_of_day if time > 0
    end

    start_time_with_wd_zone
  end

  def self.use_custom_field_where(issue)
    @use_custom_field_where = "use_custom_field = false or ("
    @use_custom_field_where += create_query_for_only_one_custom_field(issue.custom_field_values, issue)
    @use_custom_field_where += "1 = 2)"
    @use_custom_field_where
  end

  def self.create_query_for_only_one_custom_field(custom_values, issue)
    custom_values.map do |cv|
      if cv.value.is_a? Array
        ActiveRecord::Base.send(:sanitize_sql_array, ["(main_custom_field_id = ? and main_custom_field_value in (?)) or ", cv.custom_field_id, cv.value])
      else
        ActiveRecord::Base.send(:sanitize_sql_array, ["(main_custom_field_id = ? and main_custom_field_value = ?) or ", cv.custom_field_id, cv.value.to_s])
      end
    end.join('')
  end
end
