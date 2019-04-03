class VsgSla::SlaReport < VsgSla
  unloadable

  scope :create_using_issue_and_sla!, -> (issue, sla) do
    create!({
      issue_id: issue.id,
      sla_id: sla.id,
      issue_status_id: issue.status_id,
      start_time: Time.zone.now,
      principal_id: issue.assigned_to_id,
      discount_from_sla: sla.issue_statuses.to_a.include?(issue.status),
      due_time: calc_due_time(sla, issue)
    })
  end

  scope :discount_from_sla, -> { where(discount_from_sla: true) }

  scope :find_by_issue_and_sla, -> (issue, sla) do
    SlaReport.includes(:issue)
             .includes(sla: { office_hour: :working_days })
             .includes(:issue_status)
             .where(issue_id: issue.id, sla_id: sla.id)
  end

  scope :uncalc_sla_report, -> (issue, status) do
    SlaReport.includes(:issue)
             .includes(sla: { office_hour: :working_days })
             .includes(:issue_status)
             .where(issue_id: issue.id, issue_status_id: status.id, end_time: nil)
  end

  scope :total_count_working_hour, -> (issue, sla) do
    SlaReport.where(issue_id: issue.id, sla_id: sla.id, discount_from_sla: true).sum(:working_time)
  end

  scope :total_uncount_working_hour, -> (issue, sla) do
    SlaReport.where(issue_id: issue.id, sla_id: sla.id, discount_from_sla: false).sum(:working_time)
  end

  belongs_to :sla

  belongs_to :issue
  delegate :tracker, :project, to: :issue, prefix: true

  belongs_to :issue_status
  belongs_to :principal

  def self.calc_total_working_time(sla, issue)
    SlaReport.where(issue_id: issue.id, sla_id: sla.id, discount_from_sla: true).reduce(0) do |acc, sla_report|

      if sla_report.end_time
        acc + sla_report.working_time
      else
        acc + calc_working_time(issue, sla_report)
      end
    end
  end

  def self.calc_due_time(sla, issue)
    if sla.manual_date_select
      (due_time = issue.custom_field_value(sla.custom_field_id)).blank? ? nil : due_time
    else
      start_time = find_by_issue_and_sla(issue, sla).discount_from_sla.first.try(:start_time) || issue.created_on || Time.zone.now

      sla_working_hour = sla.sla

      find_by_issue_and_sla(issue, sla).each do |sla_report|
        if sla_report.end_time
          working_time = sla_report.working_time
        else
          sla_report.end_time = Time.zone.now
          working_time = calc_working_time(issue, sla_report)
        end

        if sla_report.discount_from_sla
          diff = [working_time, sla_working_hour].min
          sla_working_hour -= diff
          start_time = sla.calc_date_plus_time(start_time, diff)
          break if sla_working_hour == 0
        else
          start_time = sla.calc_date_plus_time(start_time, working_time)
        end
      end

      if sla_working_hour == 0
        start_time
      else
        sla.calc_date_plus_time(start_time, sla_working_hour)
      end
    end
  end

  def self.generate_xlsx(project, params, wb)
    sla_reports = find_by_project(project, params)

    wb.add_worksheet(name: "Time Log") do |sheet|
      sheet.add_row time_log_header

      sla_reports.each do |sla_report|
        sheet.add_row time_log_row(sla_report)
      end
    end

    slas = sla_reports.map(&:sla).uniq

    wb.add_worksheet(name: "SLA") do |sheet|
      sheet.add_row sla_header

      slas.each do |sla|
        sheet.add_row sla_row(sla)
      end
    end

    wb.add_worksheet(name: "Working Day") do |sheet|
      sheet.add_row working_day_header

      slas.map(&:office_hour).uniq.each do |office_hour|
        office_hour.working_days.each do |wd|
          sheet.add_row working_day_row(wd)
        end
      end
    end

    wb
  end

  def self.update_status_report(issue, status_was)
    uncalc_sla_report(issue, status_was).each do |sla_report|
      @end_time = Time.zone.now

      sla_report.end_time   = @end_time

      sla_report.total_time   = calc_total_time(issue, sla_report)
      sla_report.working_time = calc_working_time(issue, sla_report)
      sla_report.principal_id = issue.assigned_to_id

      sla_report.save!
    end
  end

  private

  def self.find_by_project(project, params)
    issues = Issue.where(project_id: find_visible_projects(project).map(&:id))

    issues = issues.where('issues.start_date >= ?'     , params[:start_on])  unless params[:start_on].blank?
    issues = issues.where('DATE(issues.closed_on) <= ?', params[:closed_on]) unless params[:closed_on].blank?

    includes(:issue).includes(:sla).includes(:issue_status).where(issue_id: issues)
  end

  def self.time_log_header
    [I18n.t('sla_report.sla'), I18n.t('sla_report.issue'), I18n.t('sla_report.issue_project'), I18n.t('sla_report.issue_tracker'), I18n.t('sla_report.issue_status'), I18n.t('sla_report.issue_status_is_closed'), I18n.t('sla_report.assigned_to_id'), I18n.t('sla_report.assigned_to'), I18n.t('sla_report.start_time'), I18n.t('sla_report.end_time'), I18n.t('sla_report.total_time'), I18n.t('sla_report.working_time'), I18n.t('sla_report.discount_from_sla'), I18n.t('sla_report.due_time')]
  end

  def self.time_log_row(sla_report)
    [
      sla_report.sla_id,
      sla_report.issue_id,
      sla_report.issue_project.name,
      sla_report.issue_tracker.name,
      sla_report.issue_status.name,
      sla_report.issue_status.is_closed,
      sla_report.principal.try(:id),
      "#{sla_report.principal.try(:firstname)} #{sla_report.principal.try(:lastname)}".strip,
      TimeUtils.time_with_zone(User.current.time_zone, sla_report.start_time).to_s,
      TimeUtils.time_with_zone(User.current.time_zone, sla_report.end_time).to_s,
      sla_report.total_time,
      sla_report.working_time,
      sla_report.discount_from_sla,
      TimeUtils.time_with_zone(User.current.time_zone, sla_report.due_time).to_s
    ]
  end

  def self.sla_header
    [I18n.t('sla.id'), I18n.t('sla.name'), I18n.t('sla.sla'), I18n.t('sla.office_hour')]
  end

  def self.sla_row(sla)
    [sla.id, sla.name, sla.sla, sla.office_hour_id]
  end

  def self.working_day_header
    [I18n.t('working_day.office_hour'), I18n.t('working_day.office_hour_name'), I18n.t('working_day.week_day'), I18n.t('working_day.start_time'), I18n.t('working_day.end_time'), I18n.t('office_hour.timezone')]
  end

  def self.working_day_row(working_day)
    [working_day.office_hour_id, working_day.office_hour.name, working_day.week_day, working_day.start_time.strftime("%H:%M"), working_day.end_time.strftime("%H:%M"),  working_day.office_hour.timezone]
  end

  def self.calc_working_time(issue, sla_report)
    working_time = 0.0

    start_time = sla_report.start_time
    end_time   = sla_report.end_time || Time.zone.now

    working_days = sla_report.sla.office_hour.working_days.order(:start_time)

    start_time_with_wd_zone = TimeUtils.time_with_zone(sla_report.sla.office_hour.timezone, start_time)
    end_time_with_wd_zone   = TimeUtils.time_with_zone(sla_report.sla.office_hour.timezone, end_time)

    while start_time_with_wd_zone < end_time_with_wd_zone
      is_end_date = (start_time_with_wd_zone.to_date == end_time_with_wd_zone.to_date)

      working_days.select { |wd| wd.week_day.to_s == VsgSla::WorkingDay::WEEK_DAY[start_time_with_wd_zone.wday].to_s }.each do |wd|
        next if TimeUtils.compare_times(wd.end_time, start_time_with_wd_zone) == -1
        next if is_end_date && TimeUtils.compare_times(wd.start_time, end_time_with_wd_zone) >= 0

        if TimeUtils.compare_times(start_time_with_wd_zone, wd.start_time) == -1
          start_time_with_wd_zone += TimeUtils.diff(wd.start_time, start_time_with_wd_zone).hour
        end

        if is_end_date && TimeUtils.compare_times(end_time_with_wd_zone, wd.end_time) == -1
          diff = (end_time_with_wd_zone - start_time_with_wd_zone)/3600
        else
          diff = TimeUtils.diff(wd.end_time, start_time_with_wd_zone)
        end

        working_time += diff
        start_time_with_wd_zone   += diff.hour
      end

      start_time_with_wd_zone = (start_time_with_wd_zone + 1.day).beginning_of_day
    end

    working_time
  end

  def self.calc_total_time(issue, sla_report)
    (@end_time - sla_report.start_time)/3600
  end

  def self.find_visible_projects(project)
    [project] | (project.children.visible.map { |p| find_visible_projects(p) }.inject(&:concat) || [])
  end
end
