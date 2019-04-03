class RedmineDashboardDefaultchartsController < ApplicationController
  unloadable
  before_filter :fetch_projects,
                :fetch_widget, only: [:weekly_progress, :new_by_tracker, :new_by_project, :answered_by_project, :aging_tracker, :opened_issues_status, :closed_issues_status]
  before_filter :fetch_trackers, only: [:new_by_tracker, :aging_tracker]
  before_filter :fetch_labels, only: [:weekly_progress, :new_by_tracker, :new_by_project, :answered_by_project]

  def assigned_list
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    set_assigned_to_list(projects)
    render json: @assigned_to_list.to_json
  end

  def assigned_list_per_group
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    set_assigned_to_list_per_group(projects)
    render json: @assigned_to_list_per_group.to_json
  end

  def performance_per_fte
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?
    if params[:assigned_to_id].blank?
      set_assigned_to_list_per_group(projects)
      return nil if @assigned_to_list_per_group.blank?
    end

    @labels = []

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first
    range = @widget.config[:range_day].to_i

    date_to   = params[:date_to].blank? ? Date.today : Date.parse(params[:date_to])
    date_from = params[:date_from].blank? ? (date_to - (range - 1).day) : Date.parse(params[:date_from])

    loop.with_index do |_, i|
      day = (date_from + i.day).to_date
      break if day > date_to
      @labels << day
    end

    @datasets = []

    @datasets << {
      label: "Meta",
      type: "line",

      fillColor: "rgba(187,19,62,0.5)",
      strokeColor: "rgba(187,19,62,0.8)",
      pointColor: "rgba(187,19,62,0.5)",
      pointStrokeColor: "#fff",
      pointHighlightFill: "#fff",
      pointHighlightStroke: "rgba(187,19,62,0.75)",
      data: @labels.map { @widget.config[:goal].to_i }
    }

    @datasets << {
      label: "Chamados iniciados",
      type: "bar",

      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: "rgba(237,177,17,1)",
      highlightStroke: "rgba(237,177,17,1)",
      data: []
    }

    @datasets << {
      label: "Chamados fechados",
      type: "bar",

      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: []
    }

    if params[:assigned_to_id].blank?

      values =  Issue.joins(:status).where(issue_statuses:{is_closed:true})
          .where(project_id:projects)
          .where('closed_on >= ?', date_from)
          .where('closed_on < ?', date_to + 1.day)
          .where(assigned_to_id:@assigned_to_list_per_group)
          .group('DATE(closed_on)')
          .having('count(issues.id) > ?', 0)
          .select('date(closed_on) day, count(distinct issues.id) as total, (count(distinct assigned_to_id)) as num_fte')
        openedValues = Issue.find_by_sql ["SELECT day, count(*) as total, (count(distinct start.assigned_to_id)) as num_fte from(SELECT min(journal_details.id) as total,issues.id, date(journals.created_on) as day, assigned_to_id FROM `issues` INNER JOIN `journals` ON `journals`.`journalized_id` = `issues`.`id` AND `journals`.`journalized_type` = 'Issue' INNER JOIN `journal_details` ON `journal_details`.`journal_id` = `journals`.`id` WHERE `journal_details`.`id` and `journal_details`.`prop_key` = 'status_id' AND `journal_details`.`value` = ? AND `issues`.`project_id` IN (?) AND (journals.created_on >= ?) AND (journals.created_on < ?) and assigned_to_id IN (?) GROUP BY issues.id) start group by day",Setting.plugin_redmine_dashboard_defaultcharts[:doing_status],projects,date_from, (date_to + 1.day), @assigned_to_list_per_group.select(:id)]
      # openedValues = Issue.joins([{journals: :details}])
      #     .where(journal_details: {prop_key:'status_id',value:Setting.plugin_redmine_dashboard_defaultcharts[:doing_status]})
      #     .where('journals.created_on >= ?', date_from)
      #     .where('journals.created_on < ?', date_to + 1.day)
      #     .where(project_id:projects)
      #     .where(assigned_to_id:@assigned_to_list_per_group)
      #     .group('DATE(journals.created_on)')
      #     .having("count(issues.id) > ?", 0)
      #     .select('date(journals.created_on) day, count(distinct issues.id) as total, (count(distinct assigned_to_id)) as num_fte')

      attendance = AttendanceTable.where('day >= ?', date_from)
          .where('day <= ?', date_to)
          .uniq


      @labels.each  do |l|
        closed_values = values.detect { |i| i.day == l }
        opened_values = openedValues.detect { |i| i.day == l }
        attendance_num = attendance.detect { |i| i.day == l}
        @datasets[2][:data] << (closed_values.blank? ? 0 : ((attendance_num && attendance_num.num > 0) ? closed_values.total/attendance_num.num.to_i : closed_values.total/closed_values.num_fte.to_i))
        @datasets[1][:data] << (opened_values.blank? ? 0 : ((attendance_num && attendance_num.num > 0) ? opened_values.total/attendance_num.num.to_i : opened_values.total/opened_values.num_fte.to_i))
      end

    else
      values = Issue.includes(:project).joins(:status).where(issue_statuses:{is_closed:true})
          .where(project_id:projects)
          .where('closed_on >= ?', date_from)
          .where('closed_on < ?', date_to + 1.day)
          .where('assigned_to_id = ?', params[:assigned_to_id])
          .group('assigned_to_id, DATE(closed_on)')
          .having("count(issues.id) > ?", 0)
          .count()
      openedValues = Issue.find_by_sql ["SELECT count(*) as total, day from(SELECT min(journal_details.id) as total,issues.id, date(journals.created_on) day, assigned_to_id FROM `issues` INNER JOIN `journals` ON `journals`.`journalized_id` = `issues`.`id` AND `journals`.`journalized_type` = 'Issue' INNER JOIN `journal_details` ON `journal_details`.`journal_id` = `journals`.`id` WHERE `journal_details`.`id` and `journal_details`.`prop_key` = 'status_id' AND `journal_details`.`value` = ? AND `issues`.`project_id` IN (?) AND (journals.created_on >= ?) AND (journals.created_on < ?) and assigned_to_id = ? GROUP BY issues.id) start group by day",Setting.plugin_redmine_dashboard_defaultcharts[:doing_status],projects,date_from, (date_to + 1.day), params[:assigned_to_id]]
      # openedValues = Issue.includes(:project, journals: :details)
      #     .where(journal_details: {prop_key:'status_id',value:Setting.plugin_redmine_dashboard_defaultcharts[:doing_status]})
      #     .where(project_id:projects)
      #     .where('journals.created_on >= ?', date_from)
      #     .where('journals.created_on < ?', date_to + 1.day)
      #     .where('assigned_to_id = ?', params[:assigned_to_id])
      #     .group('assigned_to_id, DATE(journals.created_on)')
      #     .having("count(issues.id) > ?", 0)
      #     .count()
      @labels.each  do |l|
        @datasets[2][:data] << ( values[l] || 0 )
        v = openedValues.detect{ |i| i.day == l}
        @datasets[1][:data] << (v.blank? ? 0 : v.total) #( openedValues[l] || 0)
      end
    end


    render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :default) },
      datasets: @datasets
    }.to_json
  end

  def projects_list
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    render json: projects.to_json
  end

  def performance_by_project
    # set_project_list
    project_id = params[:project_id]
    project = Project.find(project_id)

    @labels = []

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first
    range = @widget.config[:range_day].to_i

    date_to   = params[:date_to].blank? ? Date.today : Date.parse(params[:date_to])
    date_from = params[:date_from].blank? ? (date_to - (range - 1).day) : Date.parse(params[:date_from])

    loop.with_index do |_, i|
      day = (date_from + i.day).to_date
      break if day > date_to
      @labels << day
    end

    @datasets = []
    @datasets << {
      label: "Concluídos",
      type: "bar",
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: []
    }


    @datasets << {
      label: 'Abertos (acumulado)',
      type: "line",
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      pointColor: "rgba(237,177,17,1)",
      pointStrokeColor: "#fff",
      pointHighlightFill: "#fff",
      pointHighlightStroke: "rgba(237,177,17,1)",
      data: []
    }

    @datasets << {
      label: 'Novos',
      fillColor: 'rgba(116,118,120,0.5)',
      strokeColor: 'rgba(116,118,120,0.8)',
      highlightFill: 'rgba(116,118,120,0.75)',
      highlightStroke: 'rgba(116,118,120,1)',
      data: []
    }

    if project
      closed_values = project.issues.joins(:status)
                        .where('issue_statuses.is_closed = true and closed_on >= ? and closed_on < ?', @labels[0], @labels[-1] + 1.day)
                        .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                        .group('DATE(closed_on)')
                        .count(:id)
      open_values = project.issues.joins(:status)
                            .where('start_date < ?', @labels[0])
                            .where('DATE(closed_on) > ? or closed_on is null or (DATE(closed_on) <= ? and issue_statuses.is_closed = false)', @labels[0] - 1, @labels[0] - 1)
                            .count
      new_values = project.issues.where('start_date >= ? and start_date < ?', @labels[0], @labels[-1] + 1.day).group('DATE(start_date)').count(:id)

      @labels.each do |l|
        closed = (closed_values[l] ? closed_values[l] : 0)
        new = (new_values[l] ? new_values[l] : 0)
        open_values = open_values - closed + new

        @datasets[0][:data] << closed
        @datasets[1][:data] << open_values
        @datasets[2][:data] << new
      end
    end

    @labels.each  do |l|
      if params[:project_id].blank?
        values = Issue.where('project_id in ?',@project_list).where('DATE(closed_on) = ?', l.to_date).where('project_id is not null').group(:project_id).having("count(id) > ?", 0).count(:id).values
        @datasets[0][:data] << (values.sum / @project_list.size)
      else
        # @datasets[1][:data] << project.issues
        #   .includes([:status])
        #   .where('start_date < ?', l + 1.day)
        #   .where('DATE(closed_on) > ? or closed_on is null or (DATE(closed_on) <= ? and issue_statuses.is_closed = false)', l, l)
        #   .count
      end
    end

    render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :default) },
      datasets: @datasets
    }.to_json
  end

  def project_average_answer_time
    project = Project.find(params[:id])

    @trackers = project.trackers.order('name ASC').all
    @labels   = @trackers.map(&:name)

    max = 0

    @datasets = []

    @months = []
    3.times do |i|
      @months << Time.zone.now.end_of_month - (2 - i).months
    end

    @months.each do |month|
      @datasets << {
        label: "Tempo médio até: #{I18n.l(month.to_date, format: :month_year)}",
        fillColor: 'rgba(0,126,122,0.5)',
        strokeColor: 'rgba(0,126,122,0.8)',
        highlightFill: 'rgba(0,126,122,0.75)',
        highlightStroke: 'rgba(0,126,122,1)',
        data: []
      }
    end

    max = 0
    @trackers.each do |tracker|
      @months.each_with_index do |month, idx|
        # seconds = tracker.issues.where('start_date is not null and closed_on < ?', month).where(project_id: project.id).average('TIME_TO_SEC(TIMEDIFF(TIMESTAMP(DATE(issues.start_date)) + INTERVAL 1 DAY, issues.start_date)) + TIME_TO_SEC(TIMEDIFF(issues.closed_on, TIMESTAMP(DATE(issues.closed_on)))) + ((5 * (DATEDIFF(DATE(issues.closed_on), DATE(issues.start_date) + INTERVAL 1 DAY) DIV 7) + MID("0123444401233334012222340111123400012345001234550", 7 * WEEKDAY(DATE(issues.start_date) + INTERVAL 1 DAY) + WEEKDAY(DATE(issues.closed_on) - INTERVAL 1 DAY) + 1, 1))) * 86400').to_i
        seconds = tracker.issues.joins(:status).where(issue_statuses:{is_closed:true}).where('start_date is not null and closed_on < ?', month).where(project_id: project.id).average('TIME_TO_SEC(TIMEDIFF(closed_on, created_on))').to_i

        max = seconds if seconds > max
        @datasets[idx][:data] << seconds
      end

    end
    render json: [max, {
      labels: @labels,
      datasets: @datasets
    }].to_json
  end

  def projects_average_answer_time
    @projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if @projects.blank?

    @labels   = @projects.map(&:name)

    max = 0

    @datasets = []

    @months = []
    3.times do |i|
      @months << Time.zone.now.end_of_month - (2 - i).months
    end

    @months.each do |month|
      @datasets << {
        label: "Tempo médio até: #{I18n.l(month.to_date, format: :month_year)}",
        fillColor: 'rgba(0,126,122,0.5)',
        strokeColor: 'rgba(0,126,122,0.8)',
        highlightFill: 'rgba(0,126,122,0.75)',
        highlightStroke: 'rgba(0,126,122,1)',
        data: []
      }
    end

    @projects.each do |project|
      @months.each_with_index do |month, idx|
        seconds = project.issues.joins(:status).where(issue_statuses:{is_closed:true}).where('start_date is not null and DATE(closed_on) < ?', month).average('TIME_TO_SEC(TIMEDIFF(closed_on, created_on))').to_i

        max = seconds if seconds > max
        @datasets[idx][:data] << seconds
      end

    end

    render json: [max, {
      labels: @labels,
      datasets: @datasets
      }].to_json
    end

  def aging_project
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first

    @labels = projects.map(&:name)
    @datasets = []
    tracker_list = {}

    @datasets << {
      label: agings[0],
      fillColor: "rgba(0,126,122,0.5)",
      strokeColor: "rgba(0,126,122,0.8)",
      highlightFill: "rgba(0,126,122,0.75)",
      highlightStroke: "rgba(0,126,122,1)",
      data: @labels.map {|l| 0 }
    }

    @datasets << {
      label: agings[1],
      fillColor: "rgba(237,177,17,0.5)",
      strokeColor: "rgba(237,177,17,0.8)",
      highlightFill: "rgba(237,177,17,0.75)",
      highlightStroke: "rgba(237,177,17,1)",
      data: @labels.map {|l| 0 }
    }

    @datasets << {
      label: agings[2],
      fillColor: "rgba(116,118,120,0.5)",
      strokeColor: "rgba(116,118,120,0.8)",
      highlightFill: "rgba(116,118,120,0.75)",
      highlightStroke: "rgba(116,118,120,1)",
      data: @labels.map {|l| 0 }
    }

    @datasets << {
      label: agings[3],
      fillColor: "rgba(187,19,62,0.5)",
      strokeColor: "rgba(187,19,62,0.8)",
      highlightFill: "rgba(187,19,62,0.75)",
      highlightStroke: "rgba(187,19,62,1)",
      data: @labels.map {|l| 0 }
    }

    @datasets << {
      label: "#{agings[4]}+",
      fillColor: "rgba(105,190,40,0.5)",
      strokeColor: "rgba(105,190,40,0.8)",
      highlightFill: "rgba(105,190,40,0.75)",
      highlightStroke: "rgba(105,190,40,1)",
      data: @labels.map {|l| 0 }
    }

    projects.each_with_index do |project, index|
      project.issues.joins([:status]).where('issue_statuses.is_closed = false').where('start_date is not null').where('status_id <> ?',Setting.plugin_redmine_dashboard_defaultcharts[:waiting_status]).each do |issue|

        if issue.start_date.is_a? ActiveSupport::TimeWithZone
          days_open = ((Time.zone.now - issue.start_date)/1.day).to_i
        else
          days_open = (Time.zone.now.to_date - issue.start_date).to_i
        end

        if days_open <= agings[0].split('-')[1].to_i
          @datasets[0][:data][index] += 1
        elsif days_open <= agings[1].split('-')[1].to_i
          @datasets[1][:data][index] += 1
        elsif days_open <= agings[2].split('-')[1].to_i
          @datasets[2][:data][index] += 1
        elsif days_open <= agings[3].split('-')[1].to_i
          @datasets[3][:data][index] += 1
        else
          @datasets[4][:data][index] += 1
        end
      end
    end


    render json: {
      labels: @labels,
      datasets: @datasets
    }.to_json
  end

  def aging_per_atendent
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    set_assigned_to_list(projects)

    @labels = @assigned_to_list.map{|a|"#{a.firstname} #{a.lastname}"}
    @datasets = []
    tracker_list = {}

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first

    @datasets << {
      label: agings[0],
      fillColor: "rgba(0,126,122,0.5)",
      strokeColor: "rgba(0,126,122,0.8)",
      highlightFill: "rgba(0,126,122,0.75)",
      highlightStroke: "rgba(0,126,122,1)",
      data: @labels.map {|l| 0 }
    }

    @datasets << {
      label: agings[1],
      fillColor: "rgba(237,177,17,0.5)",
      strokeColor: "rgba(237,177,17,0.8)",
      highlightFill: "rgba(237,177,17,0.75)",
      highlightStroke: "rgba(237,177,17,1)",
      data: @labels.map {|l| 0 }
    }

    @datasets << {
      label: agings[2],
      fillColor: "rgba(116,118,120,0.5)",
      strokeColor: "rgba(116,118,120,0.8)",
      highlightFill: "rgba(116,118,120,0.75)",
      highlightStroke: "rgba(116,118,120,1)",
      data: @labels.map {|l| 0 }
    }

    @datasets << {
      label: agings[3],
      fillColor: "rgba(187,19,62,0.5)",
      strokeColor: "rgba(187,19,62,0.8)",
      highlightFill: "rgba(187,19,62,0.75)",
      highlightStroke: "rgba(187,19,62,1)",
      data: @labels.map {|l| 0 }
    }

    @datasets << {
      label: "#{agings[4]}+",
      fillColor: "rgba(105,190,40,0.5)",
      strokeColor: "rgba(105,190,40,0.8)",
      highlightFill: "rgba(105,190,40,0.75)",
      highlightStroke: "rgba(105,190,40,1)",
      data: @labels.map {|l| 0 }
    }


    @assigned_to_list.each_with_index do |atendent, index|
      Issue.joins(:project, :status)
            .where(project_id:projects)
            .where(assigned_to_id:atendent.id)
            .where('start_date is not null')
            .where('issue_statuses.is_closed = false').each do |issue|

        if issue.start_date.is_a? ActiveSupport::TimeWithZone
          days_open = ((Time.zone.now - issue.start_date)/1.day).to_i
        else
          days_open = (Time.zone.now.to_date - issue.start_date).to_i
        end


        if days_open <= agings[0].split('-')[1].to_i
          @datasets[0][:data][index] += 1
        elsif days_open <= agings[1].split('-')[1].to_i
          @datasets[1][:data][index] += 1
        elsif days_open <= agings[2].split('-')[1].to_i
          @datasets[2][:data][index] += 1
        elsif days_open <= agings[3].split('-')[1].to_i
          @datasets[3][:data][index] += 1
        else
          @datasets[4][:data][index] += 1
        end
      end
    end

    render json: {
      labels: @labels,
      datasets: @datasets
    }.to_json
  end

  def aging_has_atendent
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first
    @labels = agings
    @labels.last.concat '+'

    @datasets = []
    tracker_list = {}

    @datasets << {
      label: 'Atribuido',
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: [0, 0, 0, 0, 0]
    }

    @datasets << {
      label: 'Não atribuído',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: [0, 0, 0, 0, 0]
    }
    Issue.joins(:project, :status)
          .where(project_id:projects)
          .where('start_date < ?', Time.zone.now)
          .where('closed_on is null or (closed_on < ? and issue_statuses.is_closed = false)', Time.zone.now).each do |issue|
      if issue.start_date.is_a? ActiveSupport::TimeWithZone
        days_open = ((Time.zone.now - issue.start_date)/1.day).to_i
      else
        days_open = (Time.zone.now.to_date - issue.start_date).to_i
      end
      dataset = (issue.assigned_to_id == nil ? 1 : 0)

      if days_open <= agings[0].split('-')[1].to_i
        @datasets[dataset][:data][0] += 1
      elsif days_open <= agings[1].split('-')[1].to_i
        @datasets[dataset][:data][1] += 1
      elsif days_open <= agings[2].split('-')[1].to_i
        @datasets[dataset][:data][2] += 1
      elsif days_open <= agings[3].split('-')[1].to_i
        @datasets[dataset][:data][3] += 1
      else
        @datasets[dataset][:data][4] += 1
      end
    end


    render json: {
      labels: @labels,
      datasets: @datasets
    }.to_json
  end

  def aging_tracker
    @labels = agings
    @labels.last.concat '+'

    @datasets = []
    tracker_list = {}

    @trackers.each_with_index do |tracker, index|
      @datasets << {
        name: tracker.name,
        data: [0]*@labels.count,
        stack: 'tracker'
      }
      tracker_list[tracker.id] = index
    end

    Issue.where(project_id: @projects)
         .filtered_issues(params[:filters], @projects, exclude_statuses)
         .joins([:status]).where('start_date >= ? and start_date <= ?', params[:filters]["range_date_from"], params[:filters]["range_date_to"]).where('issue_statuses.is_closed = false', Time.zone.now).each do |issue|
      if issue.start_date.is_a? ActiveSupport::TimeWithZone
        days_open = ((Time.zone.now - issue.start_date)/1.day).to_i
      else
        days_open = (Time.zone.now.to_date - issue.start_date).to_i
      end

      next unless dataset = tracker_list[issue.tracker.id]

      agings.each_with_index do |aging, idx|
        if idx == agings.length - 1 || days_open <= aging.split('-')[1].to_i
          @datasets[dataset][:data][idx] += 1
          break
        end
      end
    end

    render json: {
      x: @labels,
      dataset: @datasets
    }.to_json
  end

  def new_by_tracker
    @datasets = []

    @trackers.uniq.each_with_index do |tracker, index|
      @datasets << {
        name: tracker.name,
        data: [],
        stack: 'tracker'
      }

      issues = tracker.issues.filtered_issues(params[:filters], @projects, exclude_statuses)
                             .where('start_date >= ?', @labels[0])
                             .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                             .where('issues.project_id in (?)', @projects.map(&:id))
                             .group_by_with_time_segmentation(time_segmentation, 'start_date')

      @labels.each_with_index do |beginning_of_month, idx|
        @datasets[index][:data][idx] = issues[beginning_of_month] || 0
      end
    end

    @labels[0] = date_from

    render json: {
      x: @labels.map { |date| I18n.l(date, format: :short) },
      dataset: @datasets
    }.to_json
  end

  def opened_issues_status
    @datasets = [{
      name: 'Status das Tarefas Abertas',
      data: []
    }]

    issues = Issue.filtered_issues(params[:filters], @projects, exclude_statuses)
                  .where('closed_on >= ? or closed_on is null or issue_statuses.is_closed = false', date_to + 1.day)
                  .where('issues.created_on < ?', date_to + 1.day)
                  .group('issue_statuses.name').count.each do |k,v|
      @datasets[0][:data] << {
        name: k,
        y: v
      }
    end

    render json: {
      dataset: @datasets
    }.to_json
  end

  def closed_issues_status
    @datasets = [{
      name: 'Status das Tarefas Abertas',
      data: []
    }]

    issues = Issue.filtered_issues(params[:filters], @projects, exclude_statuses)
                  .where('closed_on >= ?', date_from)
                  .where('closed_on < ?', date_to + 1.day)
                  .where(issue_statuses: { is_closed: true })
                  .group('issue_statuses.name').count.each do |k,v|
      @datasets[0][:data] << {
        name: k,
        y: v
      }
    end

    render json: {
      dataset: @datasets
    }.to_json
  end

  def weekly_progress
    @datasets = []

    @datasets << {
      name: 'Fechados',
      data: []
    }

     @datasets << {
      name: 'Abertos(acumulado)',
      type: 'spline',
      data: []
    }

    @datasets << {
      name: 'Novos',
      data: []
    }

    closed_issues = Issue.filtered_issues(params[:filters], @projects, exclude_statuses).select('closed_on')
                                  .where('closed_on >= ?', date_from)
                                  .where('closed_on < ?', date_to + 1.day)
                                  .where(issue_statuses: { is_closed: true })
                                  .group_by_with_time_segmentation(time_segmentation, 'closed_on')

    new_issues = Issue.filtered_issues(params[:filters], @projects, exclude_statuses).select(:start_date)
                                .where('start_date >= ?', date_from)
                                .where('start_date < ?', date_to + 1.day)
                                .group_by_with_time_segmentation(time_segmentation, "start_date")

    @labels.each_with_index do |beginning_of_period, idx|
      @datasets[0][:data][idx] = (closed_issues[beginning_of_period] ? closed_issues[beginning_of_period] : 0)
      @datasets[2][:data][idx] = (new_issues[beginning_of_period] ? new_issues[beginning_of_period]: 0)

      if idx == 0
        end_of_period = [end_of_period_with_time_segmentation(beginning_of_period, time_segmentation), date_to].min

        @datasets[1][:data][idx] = Issue.filtered_issues(params[:filters], @projects, exclude_statuses)
                                        .where('start_date <= ?', end_of_period)
                                        .where("closed_on > ? or closed_on is null or (closed_on < ? and #{IssueStatus.table_name}.is_closed = false)", end_of_period, end_of_period)
                                        .count
      else
        @datasets[1][:data][idx] = @datasets[1][:data][idx - 1] - @datasets[0][:data][idx] + @datasets[2][:data][idx]
      end
    end

    @labels[0] = date_from

    render json: {
      x: @labels.map { |date| I18n.l(date, format: :short) },
      dataset: @datasets
    }.to_json
  end

  def answered_by_project
    @datasets = []
    @projects.each_with_index do |project, idx_project|
      @datasets << {
        name: project.name,
        data: [0]
      }

      issues = Issue.filtered_issues(params[:filters], [project], exclude_statuses)
        .includes(relations_from: {issue_to: :status})
        .where(issue_statuses: { is_closed: true }).where('closed_on >= ?', @labels[0])
        .group_by_with_time_segmentation(time_segmentation, "closed_on")

      @labels.each_with_index do |beginning_of_month, idx_label|
        @datasets[idx_project][:data][idx_label] = issues[beginning_of_month] || 0
      end
    end

    @labels[0] = date_from

    render json: {
      x: @labels.map { |date| I18n.l(date, format: :short) },
      dataset: @datasets
    }.to_json
  end

  def new_by_project
    @datasets = []

    @projects.each_with_index do |project, index|
      @datasets << {
        name: project.name,
        data: [0]
      }

      issues = Issue.filtered_issues(params[:filters], @projects, exclude_statuses)
                             .where(project_id: project).where('Date(start_date) >= ?', @labels[0])
                             .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                             .group_by_with_time_segmentation(time_segmentation, "start_date")

      @labels.each_with_index do |beginning_of_month, idx|
        @datasets[index][:data][idx] = issues[beginning_of_month] || 0
      end
    end

    @labels[0] = date_from

    render json: {
      x: @labels.map { |date| I18n.l(date, format: :short) },
      dataset: @datasets
    }.to_json
  end

  protected

  def group_by_type(i, type)
    if type == "closed"
      i.closed_on
    else
      i.start_date
    end
  end

  def fetch_projects
    @projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
  end

  def fetch_widget
    @widget = RedmineWidget.where(name_id: params[:widget_id]).first
  end

  def fetch_labels
    @labels = []

    loop.with_index do |_, i|
      time = add_time_with_segmentation(date_from.to_date, i, time_segmentation)
      break if time > date_to.to_date
      @labels << time
    end
  end

  def agings
    @agings ||= @widget.config[:aging].split(/\s+/)
  end

  def date_to
    params[:filters][:range_date_to].to_date
  end

  def date_from
    params[:filters][:range_date_from].to_date
  end

  def time_segmentation
    params[:filters][:time_segmentation]
  end

  def priority_id
    @priority_id ||= params[:filters][:priority_id].blank? ? IssuePriority.all.select(:id) : params[:filters][:priority_id]
  end

  def tracker_id
    @tracker_id ||= params[:filters][:tracker_id].blank? ? Tracker.all.select(:id) : params[:filters][:tracker_id]
  end

  def add_time_with_segmentation(date_from, i, time_segmentation)
    (date_from.to_date.send("beginning_of_#{time_segmentation}") + i.send("#{time_segmentation}s")).to_date
  end

  def end_of_period_with_time_segmentation(beginning_of_period, time_segmentation)
    if time_segmentation == "day"
      beginning_of_period
    elsif time_segmentation == "week"
      beginning_of_period.end_of_week
    elsif time_segmentation == "month"
      beginning_of_period.end_of_month
    else time_segmentation == "year"
      beginning_of_period.end_of_year
    end
  end

  def exclude_statuses
    return [0] if @widget.config[:exclude_statuses].blank?
    @exclude_statuses ||= @widget.config[:exclude_statuses].split(/\s+/)
  end

  def set_assigned_to_list_per_group(projects)
    users = users_allowed(projects)
    if users == nil
      @assigned_to_list_per_group = User.joins('LEFT OUTER JOIN issues ON issues.assigned_to_id = users.id').where(issues: {project_id: projects}).uniq
    else
      users << User.current.id
      @assigned_to_list_per_group = User.joins('LEFT OUTER JOIN issues ON issues.assigned_to_id = users.id').where(id:users).where(issues: {project_id: projects}).uniq
    end
  end

  def set_assigned_to_list(projects)
    @assigned_to_list = User.joins('LEFT OUTER JOIN issues ON issues.assigned_to_id = users.id').where(issues: {project_id: projects}).uniq
  end

  def users_allowed(projects)
    return nil if User.current.admin?
    users = []
    projects.each do |project|
      User.current.roles_for_project(project).each do |role|
        groups = Role.joins('INNER JOIN roles_groups ON id = roles_groups.role_id')
            .joins('INNER JOIN users ON users.id = roles_groups.group_id')
            .where(id:role).select("users.id").uniq
        return nil if groups.empty?
        groups.each do |group|
          Group.joins(:users).where(id:group.id).select("groups_users.user_id").each do |user|
            users << user.user_id
          end
        end
      end
    end
    users
  end

  def fetch_trackers
    @trackers = @projects.map { |p| p.trackers.where(id: tracker_id) }.flatten.uniq
  end
end
