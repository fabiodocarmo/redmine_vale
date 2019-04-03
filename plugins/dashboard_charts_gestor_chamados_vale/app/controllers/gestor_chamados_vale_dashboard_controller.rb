# encoding: UTF-8
class GestorChamadosValeDashboardController < ApplicationController
  unloadable
  skip_before_filter :check_if_login_required
  skip_before_filter :verify_authenticity_token
  accept_api_auth :index, :show, :create, :update, :destroy


  def aging_n1_n2
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first

    @labels = agings
    @labels.last.concat '+'

    @datasets = []
    tracker_list = {}

    @datasets << {
      label: 'N1',
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: [0, 0, 0, 0, 0]
    }

    @datasets << {
      label: 'N2',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: [0, 0, 0, 0, 0]
    }

    Issue.joins([:project, :status]).includes(:relations_to)
         .where(project_id: projects)
         .where('start_date < ?', Time.zone.now)
         .where('issue_statuses.is_closed = false').each do |issue|

      days_open = (Time.zone.now - issue.start_date).to_i / 1.day

      if issue.relations == nil || issue.relations.size == 0
        dataset = 0
      else
        issue.relations.each do |issue_n2|
        #issue_n2 = Issue.where(id:issue.issue_to_id)
          if issue_n2.issue_to.status.is_closed || issue_n2.issue_to.status_id == 8
            dataset = 0
          else
            dataset = 1
          end
        end
      end

      if days_open <= 7
        @datasets[dataset][:data][0] += 1
      elsif days_open <= 15
        @datasets[dataset][:data][1] += 1
      elsif days_open <= 30
        @datasets[dataset][:data][2] += 1
      elsif days_open <= 60
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

 def answered_by_level
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first

    @labels = []
    12.times do |i|
      @labels << (Date.today - (11 - i).months).end_of_month
    end
    @datasets = []

    @datasets << {
      label: 'N1',
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    @datasets << {
      label: 'N2',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    issues = Issue.joins([:project, :status, :author]).includes(relations_from: {issue_to: :status})
        .where(issue_statuses: { is_closed: true })
        .where(project_id: projects)
        .where('issues.closed_on >= ?', @labels[0])
        .where('issues.status_id not in (?)', exclude_statuses)

    issues_n2 = issues
        .where(statuses_issues: { id: [Setting.plugin_redmine_gestor_chamadas[:answered_status].to_i, Setting.plugin_redmine_gestor_chamadas[:archived_status].to_i]})
        .where('statuses_issues.id not in (?)', exclude_statuses)

    issues_n1 = issues
        .where('issues.id not in (?)', issues_n2.pluck(:id))

    issues_n1 = issues_n1.group('last_day(issues.closed_on)').count
    issues_n2 = issues_n2.group('last_day(issues.closed_on)').count

    @labels.each_with_index do |end_of_month, idx|
      @datasets[0][:data][idx] = issues_n1[end_of_month] if issues_n1[end_of_month]
      @datasets[1][:data][idx] = issues_n2[end_of_month] if issues_n2[end_of_month]
    end

    render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :month_year) },
      datasets: @datasets
    }.to_json
  end

  def answered_by_level_sla
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first
    range = @widget.config[:range_day].to_i

    tracker_id   = params[:tracker_id]
    date_to   = params[:date_to].blank? ? Date.today : Date.parse(params[:date_to])
    date_from = params[:date_from].blank? ? (date_to - (range - 1).day) : Date.parse(params[:date_from])

    @labels = []
    loop.with_index do |_, i|
      day = (date_from + i.day).to_date
      break if day > date_to
      @labels << day
    end

    @datasets = {}

    @datasets[:on_time_percentage] = [{
      label: 'Dentro do prazo',
      type: "line",
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      pointColor: 'rgba(0,126,122,0.5)',
      pointStrokeColor: 'rgba(0,126,122,0.7)',
      pointHighlightFill: 'rgba(0,126,122,0.75)',
      pointHighlightStroke: 'rgba(0,126,122,1)',
      data: []
    }]

    @datasets[:on_time_percentage] << {
      label: 'N2',
      type: "line",
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      pointColor: "rgba(237,177,17,0.5)",
      pointStrokeColor: "rgba(237,177,17,0.7)",
      pointHighlightFill: 'rgba(237,177,17,0.8)',
      pointHighlightStroke: 'rgba(237,177,17,1)',
      data: []
    }

    @datasets[:on_time] = [{
      label: 'N1',
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: []
    }]

    @datasets[:on_time] << {
      label: 'N2',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.8)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: []
    }

    issues = Issue.joins([:project, :status, :author]).includes(relations_from: {issue_to: :status})
      .where(issue_statuses: { is_closed: true })
      .where(users:{type:'AnonymousUser'})
      .where(project_id: projects)
      .where('issues.closed_on >= ?', @labels[0])

    issues_n2 = issues.where(statuses_issues: {
                              id: [
                                Setting.plugin_redmine_gestor_chamadas[:answered_status].to_i,
                                Setting.plugin_redmine_gestor_chamadas[:archived_status].to_i
                              ]
                            })

    unless exclude_statuses.blank?
      issues = issues.where('issues.status_id not in (?)', exclude_statuses)
      issues_n2 = issues.where('statuses_issues.id not in (?)', exclude_statuses)
    end

    unless tracker_id.blank?
      issues = issues.where(tracker_id: tracker_id)
    end

    issues_n1 = issues.where('issues.id not in (?)', issues_n2.select('issues.id'))

    issues_n1 = issues_n1.group('date(issues.closed_on)')
      .group('case when ((issues.due_date is not null) and issues.closed_on > issues.due_date) then 0 else 1 end')
      .count
    issues_n2 = issues_n2.group('date(issues.closed_on)')
      .group('case when ((issues.due_date is not null) and issues.closed_on > issues.due_date) then 0 else 1 end')
      .count

    n1_prazo_acumulado = n1_fora_acumulado = n2_prazo_acumulado = n2_fora_acumulado = 0
    @labels.each_with_index do |day_of_month, idx|
      n1_prazo = issues_n1[[day_of_month, 1]] || 0
      n1_fora  = issues_n1[[day_of_month, 0]] || 0
      n2_prazo = issues_n2[[day_of_month, 1]] || 0
      n2_fora  = issues_n2[[day_of_month, 0]] || 0
      total = (n1_prazo + n1_fora + n2_prazo + n2_fora)

      @datasets[:on_time_percentage][0][:data][idx] = total > 0 ? ('%.2f' % (100.0 * (n1_prazo + n2_prazo) / total)) : 0
      @datasets[:on_time_percentage][1][:data][idx] = total > 0 ? ('%.2f' % (100.0 * (n2_prazo + n2_fora) / total)) : 0

      @datasets[:on_time][0][:data][idx] = n1_prazo + n1_fora
      @datasets[:on_time][1][:data][idx] = n2_prazo + n2_fora

      n1_prazo_acumulado += n1_prazo
      n1_fora_acumulado  += n1_fora
      n2_prazo_acumulado += n2_prazo
      n2_fora_acumulado  += n2_fora
    end
    total_acumulado = (n1_prazo_acumulado + n1_fora_acumulado + n2_prazo_acumulado + n2_fora_acumulado)

    @labels = @labels.map { |date| I18n.l(date.to_date, format: :default) }

    @datasets[:on_time_percentage][0][:data] << (total_acumulado > 0 ? ('%.2f' % (100.0 * (n1_prazo_acumulado + n2_prazo_acumulado) / total_acumulado)) : 0)
    @datasets[:on_time_percentage][1][:data] << (total_acumulado > 0 ? ('%.2f' % (100.0 * (n2_prazo_acumulado + n2_fora_acumulado) / total_acumulado)) : 0)

    @datasets[:on_time][0][:data] << n1_prazo_acumulado + n1_fora_acumulado
    @datasets[:on_time][1][:data] << n2_prazo_acumulado + n2_fora_acumulado

    data = {
      on_time_percentage: { labels: @labels + ["Acumulado"], datasets: @datasets[:on_time_percentage] },
      on_time: { labels: @labels, datasets: @datasets[:on_time] }
    }

    render json: data.to_json
  end

  def project_list
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])

    render json: projects.to_json
  end

  def free_money
    @labels = []
    12.times do |i|
      @labels << Time.zone.now.beginning_of_month - (11 - i).months
    end
    @datasets = []

    @datasets << {
      label: 'Montante Liberado',
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    @datasets << {
      label: 'Montante Conciliado',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17, 1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    value_field_ids = CustomField.where(value_field: true).pluck(:id)

    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?


    issues = Issue.where(project_id:projects).includes([:tracker, :custom_values, :status]).where('custom_values.custom_field_id in (?)', value_field_ids).where('closed_on is not null').where('trackers.frees_value').where(issue_statuses: { is_closed: true }).group_by {|i| i.closed_on.beginning_of_month}

    @labels.each_with_index do |beginning_of_month, idx|
      next unless issues[beginning_of_month]

      value_field_ids.each do |value_field_id|
        @datasets[0][:data][idx] += issues[beginning_of_month].map { |i| (cv = i.custom_value_for(value_field_id)) ? cv.value.to_f : 0 }.sum
      end
    end

    issues = Issue.where(project_id:projects).includes([:tracker, :custom_values, :status])
                .where('custom_values.custom_field_id in (?)', value_field_ids)
                .where('closed_on is not null')
                .where('trackers.reconciles_value')
                .where(issue_statuses: { is_closed: true })
                .group_by {|i| i.closed_on.beginning_of_month}

    @labels.each_with_index do |beginning_of_month, idx|
      next unless issues[beginning_of_month]

      value_field_ids.each do |value_field_id|
        @datasets[1][:data][idx] += issues[beginning_of_month].map { |i| (cv = i.custom_value_for(value_field_id)) ? cv.value.to_f : 0 }.sum
      end
    end

    render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :month_year) },
      datasets: @datasets
    }.to_json
  end

  def customer_by_issue_number_list
    set_customer_by_issue_number
    render json: @customers.to_json
  end

  def customer_by_issue_number_monthly_progress
    @labels = []
    12.times do |i|
      @labels << Time.zone.now.beginning_of_month - (11 - i).months
    end
    @datasets = []

    @datasets << {
      label: 'Fechados no Mês',
      fillColor: 'rgba(116,118,120,0.5)',
      strokeColor: 'rgba(116,118,120,0.8)',
      highlightFill: 'rgba(116,118,120,0.75)',
      highlightStroke: 'rgba(116,118,120,1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    project = Project.find(Setting.plugin_redmine_gestor_chamadas[:project])
    customer = params[:customer]

    issues = project.issues.includes(:customer)
      .where('contacts.company = ?', customer)
      .where('closed_on >= ?', @labels[0])
      .includes([:status])
      .where('due_date is not null')
      .where(issue_statuses: { is_closed: true })
      .group_by {|i| i.closed_on.beginning_of_month}


    @labels.each_with_index do |beginning_of_month, idx|
      @datasets[0][:data][idx] = issues[beginning_of_month].length if issues[beginning_of_month]
    end

    @datasets << {
      label: 'Abertos(acumulado)',
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    @labels.each_with_index do |beginning_of_month, idx|
      end_of_month = beginning_of_month.end_of_month

      @datasets[1][:data][idx] = project.issues
        .includes([:status]).includes(:customer)
        .where('contacts.company = ?', customer)
        .where('start_on < ?', end_of_month)
        .where('closed_on > ? or closed_on is null or (closed_on < ? and issue_statuses.is_closed = false)', end_of_month, end_of_month)
        .where('due_date is not null').count
    end

    @datasets << {
      label: 'Novos no Mês',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    issues = project.issues.includes(:customer)
      .where('contacts.company = ?', customer)
      .where('start_on >= ?', @labels[0])
      .where('due_date is not null')
      .group_by {|i| i.start_on.beginning_of_month}

    @labels.each_with_index do |beginning_of_month, idx|
      @datasets[2][:data][idx] = issues[beginning_of_month].length if issues[beginning_of_month]
    end


    render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :month_year) },
      datasets: @datasets
    }.to_json
  end

  def customer_by_issue_number_total
    render json: Issue.includes(:tracker).includes(:customer)
                  .where('contacts.id is not null')
                  .group('trackers.has_invoice').count.to_json
  end

  def customer_by_issue_number
    set_customer_by_issue_number
    @labels = @customers.map { |c| c.truncate(25) }
    @datasets = []

    @datasets << {
      label: 'Com nota fiscal',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: []
    }

    @datasets << {
      label: 'Sem nota fiscal',
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: []
    }

    @customers.each do |customer|
      @datasets[0][:data] << Issue.includes(:customer).includes(:tracker)
                              .where('contacts.company = ?', customer)
                              .where(trackers: {has_invoice: true}).count

      @datasets[1][:data] << Issue.includes(:customer).includes(:tracker)
                              .where('contacts.company = ?', customer)
                              .where(trackers: {has_invoice: false}).count
    end

    render json: {
      labels: @labels,
      datasets: @datasets
    }.to_json
  end

  def archive_issue
    issue_id = params[:id]
    issue = Issue.find(issue_id)
    @user = User.find(params[:user])

    @new_journal = Journal.new(:journalized => issue, :user => @user)
    @new_journal.details << JournalDetail.new(:property => 'attr', :prop_key => 'status_id',:old_value => issue.status_id, :value => Setting.plugin_redmine_gestor_chamadas[:archived_status])
    issue.journals << @new_journal

    issue.status_id = Setting.plugin_redmine_gestor_chamadas[:archived_status]
    issue.save

    redirect_to issue_path(issue_id)
  end

  protected

  def agings
    @agings ||= @widget.config[:aging].split(/\s+/)
  end

  def exclude_statuses
    return "" if @widget.config[:exclude_statuses].blank?
    @exclude_statuses ||= @widget.config[:exclude_statuses].split(/\s+/)
  end

  def set_customer_by_issue_value
    value_field_ids = CustomField.where(value_field: true).pluck(:id)
    @customers = @customers = Issue.includes(:customer).includes(:custom_values).group('contacts.company').where('contacts.id is not null').where('custom_values.custom_field_id in (?)', value_field_ids).where('due_date is not null').order('sum_custom_values_value DESC').sum("custom_values.value").keys[0..9]
  end

  def set_customer_by_issue_number
    @customers = Issue.includes(:customer).where('contacts.id is not null')
                  .group('contacts.company')
                  .order('count_id DESC').limit(10).count.keys
  end


end
