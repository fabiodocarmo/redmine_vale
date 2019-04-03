# encoding: UTF-8
class GestorChamadosDashboardController < ApplicationController
  unloadable
  skip_before_filter :check_if_login_required
  skip_before_filter :verify_authenticity_token
  accept_api_auth :index, :show, :create, :update, :destroy

  def new_by_tracker_by_contact
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    @labels = []

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first
    range = @widget.config[:range_month].to_i
    range.times do |i|
      @labels << (Time.zone.now.beginning_of_month - (range - 1 - i).months).to_date
    end

    trackers = []

    customer_id = params[:customer]

    projects.each do |project|
      trackers.concat(project.trackers)
    end

    @datasets = []

    color = Paleta::Color.new(:hex, "00B0CA")
    palette = Paleta::Palette.generate(type: :split_complement, from: :color, size: 3, color: color)
    palette = Paleta::Palette.generate(type: :split_complement, from: :color, size: 3, color: palette[1])
    trackers.uniq.each_with_index do |tracker, index|

      case index
      when 0
        rgb = "0,126,122"
      when 1
        rgb = "237,177,17"
      when 2
        rgb = "116,118,120"
      when 3
        rgb = "187,19,62"
      when 4
        rgb = "227,114,34"
      when 5
        rgb = "61,126,219"
      when 6
        rgb = "0,176,202"
      when 7
        rgb = "105,190,40"
      when 8
        rgb = "223,223,0"
      when 9
        color = Paleta::Color.new(:hex, "00B0CA")
        palette = Paleta::Palette.generate(type: :split_complement, from: :color, size: 3, color: color)
        palette = Paleta::Palette.generate(type: :split_complement, from: :color, size: 3, color: palette[1])
        rgb = palette[0].to_array(:rgb).map(&:to_i).join(',')
        palette = Paleta::Palette.generate(type: :split_complement, from: :color, size: 3, color: palette[1])
      else
        rgb = palette[0].to_array(:rgb).map(&:to_i).join(',')
        palette = Paleta::Palette.generate(type: :split_complement, from: :color, size: 3, color: palette[1])
      end

      @datasets << {
        label: tracker.name,
        fillColor: "rgba(#{rgb},0.5)",
        strokeColor: "rgba(#{rgb},0.8)",
        highlightFill: "rgba(#{rgb},0.75)",
        highlightStroke: "rgba(#{rgb},1)",
        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      }

      if customer_id.blank?
        issues = tracker.issues.where('start_date >= ?', @labels[0])
          .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
          .where('issues.project_id in (?)', projects.map(&:id))
          .group('date_add(DATE(start_date),interval -DAY(DATE(start_date))+1 DAY)').count('issues.id')
      else
        customer = Contact.find(customer_id).first_name
        issues = tracker.issues.includes(:customer)
          .where('contacts.company = ?', customer)
          .where('start_date >= ?', @labels[0])
          .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
          .where('issues.project_id in (?)', projects.map(&:id))
          .group('date_add(DATE(start_date),interval -DAY(DATE(start_date))+1 DAY)').count('issues.id')
      end
      @labels.each_with_index do |beginning_of_month, idx|
        @datasets[index][:data][idx] = issues[beginning_of_month] if issues[beginning_of_month]
      end
    end

    render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :month_year) },
      datasets: @datasets
    }.to_json
  end

  def weekly_progress_by_contact
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    @labels = []

    @widget = RedmineWidget.where(name_id: params[:widget_id]).first
    range = @widget.config[:range_week].to_i

    customer_id = params[:customer]

    if customer_id.blank?
      customer = nil
    else
      customer = Contact.find(customer_id).first_name
    end

    date_to   = params[:date_to].blank? ? Date.today : Date.parse(params[:date_to])
    date_from = params[:date_from].blank? ? (date_to - (range - 1).weeks) : Date.parse(params[:date_from])

    loop.with_index do |_, i|
      week = (date_from.beginning_of_week + i.weeks).to_date
      break if week > date_to
      @labels << week
    end

    @datasets = []

    @datasets << {
      label: 'Fechados na Semana',
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: []
    }

    @datasets << {
      label: 'Abertos(acumulado)',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: []
    }

    @datasets << {
      label: 'Novos na Semana',
      fillColor: 'rgba(116,118,120,0.5)',
      strokeColor: 'rgba(116,118,120,0.8)',
      highlightFill: 'rgba(116,118,120,0.75)',
      highlightStroke: 'rgba(116,118,120,1)',
      data: []
    }



    if customer_id.blank?
      closed_issues = Issue.select('closed_on')
                .joins([:project, :status])
                .where(project_id: projects)
                .where('closed_on >= ?', date_from)
                .where('closed_on < ?', date_to + 1.day)
                .where(issue_statuses: { is_closed: true })
                .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                .group_by {|i| i.closed_on.to_date.beginning_of_week}
    else
      closed_issues = Issue.select('closed_on')
                .joins([:project, :status])
                .joins(:customer).where('contacts.company = ?', customer)
                .where(project_id: projects)
                .where('closed_on >= ?', date_from)
                .where('closed_on < ?', date_to + 1.day)
                .where(issue_statuses: { is_closed: true })
                .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                .group_by {|i| i.closed_on.to_date.beginning_of_week}
    end


    if customer_id.blank?
      new_issues = Issue.select(:start_date)
                .joins(:project)
                .where(project_id:projects)
                .where('start_date >= ?', date_from)
                .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                .group_by {|i| i.start_date.to_date.beginning_of_week}
    else
      new_issues = Issue.select(:start_date)
                .joins([:project])
                .where(project_id:projects)
                .joins(:customer).where('contacts.company = ?', customer)
                .where('start_date >= ?', date_from)
                .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                .group_by {|i| i.start_date.to_date.beginning_of_week}
    end


    @labels.each_with_index do |beginning_of_week, idx|
      @datasets[0][:data][idx] = (closed_issues[beginning_of_week] ? closed_issues[beginning_of_week].length : 0)
      @datasets[2][:data][idx] = (new_issues[beginning_of_week] ? new_issues[beginning_of_week].length : 0)
      if idx == 0
        end_of_week = [beginning_of_week.end_of_week, date_to].min
        if customer_id.blank?
          @datasets[1][:data][idx] = Issue.joins([:project])
                    .where(project_id:projects)
                    .joins([:status])
                    .where('start_date < ?', end_of_week  + 1.day)
                    .where('closed_on > ? or closed_on is null or (closed_on < ? and issue_statuses.is_closed = false)', end_of_week, end_of_week)
                    .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                    .count
        else
          @datasets[1][:data][idx] = Issue.joins([:project])
                    .where(project_id:projects)
                    .joins(:customer).where('contacts.company = ?', customer)
                    .joins([:status])
                    .where('start_date < ?', end_of_week + 1.day)
                    .where('closed_on > ? or closed_on is null or (closed_on < ? and issue_statuses.is_closed = false)', end_of_week, end_of_week)
                    .where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
                    .count
        end
      else
        @datasets[1][:data][idx] = @datasets[1][:data][idx - 1] -  @datasets[0][:data][idx] + @datasets[2][:data][idx]
      end

    end

    @labels[0] = date_from

    render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :short) },
      datasets: @datasets
    }.to_json
  end

  def customer_by_issue_value_list
    set_customer_by_issue_value
    render json: @customers.to_json
  end

  def customer_by_issue_value_monthly_progress
    @labels = []
    12.times do |i|
      @labels << Time.zone.now.beginning_of_month - (11 - i).months
    end
    @datasets = []

    @datasets << {
      label: 'Fechados no Mês',
      fillColor: 'rgba(0,0,0,0.5)',
      strokeColor: 'rgba(116,118,120,0.8)',
      highlightFill: 'rgba(116,118,120,0.75)',
      highlightStroke: 'rgba(116,118,120,1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    value_field_ids = CustomField.where(value_field: true).pluck(:id)
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?
    customer = params[:customer]

    issues = Issue.where(project_id: projects)
              .find_customer(customer)
              .find_values
              .where('closed_on >= ?', @labels[0])
              .joins([:status])
              .where('due_date is not null')
              .where(issue_statuses: { is_closed: true })
              .group_by {|i| i.closed_on.beginning_of_month}

    @labels.each_with_index do |beginning_of_month, idx|
      next unless issues[beginning_of_month]

      value_field_ids.each do |value_field_id|
        @datasets[0][:data][idx] += issues[beginning_of_month].map { |i| (cv = i.custom_value_for(value_field_id)) ? cv.value.to_f : 0 }.sum
      end
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

      @datasets[1][:data][idx] = Issue.where(project_id: projects)
        .joins([:status])
        .find_customer(customer)
        .find_values
        .joins(:custom_values)
        .where('start_date < ?', end_of_month)
        .where('closed_on > ? or closed_on is null or (closed_on < ? and issue_statuses.is_closed = false)', end_of_month, end_of_month)
        .where('due_date is not null').sum("value_field.value")
    end

    @datasets << {
      label: 'Novos no Mês',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    issues = Issue.where(project_id: projects)
                  .find_customer(customer)
                  .find_values
                  .where('start_date >= ?', @labels[0])
                  .where('due_date is not null')
                  .group_by {|i| i.start_date.beginning_of_month}

    @labels.each_with_index do |beginning_of_month, idx|
      next unless issues[beginning_of_month]

      value_field_ids.each do |value_field_id|
        @datasets[2][:data][idx] += issues[beginning_of_month].map { |i| (cv = i.custom_value_for(value_field_id)) ? cv.value.to_f : 0 }.sum
      end
    end

    render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :month_year) },
      datasets: @datasets
    }.to_json
  end

  def customer_by_issue_value_total
    value_field_ids = CustomField.where(value_field: true).pluck(:id)
    render json: Issue.joins(:tracker)
      .joins(:custom_values)
      .where('custom_values.custom_field_id in (?)', value_field_ids)
      .group('trackers.has_invoice')
      .sum("custom_values.value")
      .to_json
  end

  def customer_by_issue_value
    set_customer_by_issue_value

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
      @datasets[0][:data] << Issue
              .group_customers_by_cnpj_cpf
              .find_values
              .joins(:tracker)
              .where('due_date is not null')
              .where(trackers: {has_invoice: true})
              .sum("value_field.value")

      @datasets[1][:data] << Issue
              .group_customers_by_cnpj_cpf
              .find_values
              .joins(:tracker)
              .where('due_date is not null')
              .where(trackers: {has_invoice: false})
              .sum("value_field.value")
    end

    render json: {
      labels: @labels,
      datasets: @datasets
    }.to_json
  end

  def project_list
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])

    render json: projects.map { |p| { project: { id: p.id, name: p.name } } }.to_json
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
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?
    customer = params[:customer]
    issues = Issue.where(project_id:projects)
        .find_customer(customer["cnpj_cpf"])
        .where('closed_on >= ?', @labels[0])
        .joins([:status])
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

      @datasets[1][:data][idx] = Issue.where(project_id:projects)
        .joins([:status])
        .find_customer(customer["cnpj_cpf"])
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

    issues = Issue.where(project_id:projects)
      .find_customer(customer["cnpj_cpf"])
      .where('start_on >= ?', @labels[0])
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
    render json: Issue.joins(:tracker)
                  .where(project_id: [1, 32, 33])
                  .group('trackers.has_invoice').count.to_json
  end

  def customer_by_issue_number
    set_customer_by_issue_number
    @labels = @customers.map {|c| "#{c.cnpj_cpf.length == 8 ? c.cnpj_cpf + "XXXX-XX" : c.cnpj_cpf} - #{c.social_name.truncate(25)}"}
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

    i = Issue.joins([:tracker, :custom_values])
    i_customers = i
    @customers.each do |customer|
      i_customers = i_customers.where('custom_values.value like concat(?, \'%\')', customer.cnpj_cpf)
    end
    i_customers = i_customers.where_values.join(' or ')
    i = i.where(custom_values: {custom_field_id: Setting.plugin_redmine_gestor_chamadas[:customer_field]})
          .where(project_id: [1, 32, 33])
          .where(i_customers)
          .group('case
                    when (length(custom_values.value) = 14)
                      then mid(custom_values.value, 1, 8)
                    else
                      custom_values.value
                    end,
                    trackers.has_invoice')
          .select('(case
                    when (length(custom_values.value) = 14)
                      then mid(custom_values.value, 1, 8)
                    else
                      custom_values.value
                    end) cnpj_cpf,
                    trackers.has_invoice, count(issues.id) count_all')
    i = i.group_by { |c| c.cnpj_cpf }

    @customers.each do |customer|
      @datasets[0][:data] << i[customer.cnpj_cpf].select { |c| c.has_invoice == 1 }.first.count_all
      @datasets[1][:data] << i[customer.cnpj_cpf].select { |c| c.has_invoice == 0 }.first.count_all
    end

    render json: {
      labels: @labels,
      datasets: @datasets
    }.to_json
  end

  def customer_by_reopened_issues
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    return if projects.blank?

    datasets = [{
      label: 'Chamados reabertos',
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: []
    }]

    date_to   = params[:date_to].blank? ? Date.today : Date.parse(params[:date_to])
    date_from = params[:date_from].blank? ? date_to.beginning_of_month : Date.parse(params[:date_from])

    all_reopened_issues = reopened_issues
                  .where('journals.created_on > ?', date_from)
                  .where('journals.created_on < ?', (date_to + 1.day))
                  .where(project_id: projects)
    total = all_reopened_issues.count

    if total > 0
      customers = top_customers_by_issues(all_reopened_issues, 10)
      labels = customers.map { |c| c.truncate(25) }

      reopened_issues_by_customer = all_reopened_issues.includes(:customer)
                                      .where(contacts: {company: customers})
                                      .group(:company)
                                      .count
      customers.each do |customer|
        datasets[0][:data] << reopened_issues_by_customer[customer]
      end
    else
      labels = ['Nenhum chamado reaberto no período']
      datasets[0][:data] = [0]
    end

    render json: {
      labels: labels,
      datasets: datasets,
      total: total,
      range_date_from: I18n.l(date_from, format: :default),
      range_date_to: I18n.l(date_to, format: :default)
    }.to_json
  end

  def resolver_areas
    projects = DashboardProjects.valid_projects(params[:widget_id],params[:project_id])
    render json: projects.map { |p| { project: { id: p.id, name: p.name } } }.to_json
  end

  def wrong_issues_per_project
    project = Project.find(params[:project_id])
    return if project.blank?
    @widget = RedmineWidget.where(name_id: params[:widget_id]).first

    @labels = []
    12.times do |i|
      @labels << Time.zone.now.beginning_of_month - (11 - i).months
    end
    @datasets = []

    answered_statuses = []
    answered_statuses << IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:answered_status])
    answered_statuses << IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:archived_status])

    @datasets << {
      label: @widget.config[:answered_label],
      fillColor: 'rgba(0,126,122,0.5)',
      strokeColor: 'rgba(0,126,122,0.8)',
      highlightFill: 'rgba(0,126,122,0.75)',
      highlightStroke: 'rgba(0,126,122,1)',
      data: []
    }

    mistaken_status = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:mistaken_status])
    @datasets << {
      label: @widget.config[:mistaken_forwarding_label],
      fillColor: 'rgba(237,177,17,0.5)',
      strokeColor: 'rgba(237,177,17,0.8)',
      highlightFill: 'rgba(237,177,17,0.75)',
      highlightStroke: 'rgba(237,177,17,1)',
      data: []
    }

    @labels.each do |month|
      @datasets[0][:data] << project.issues.where(status_id: answered_statuses).where("closed_on >= ? and closed_on <= ?", month.beginning_of_month, month.end_of_month).count

      @datasets[1][:data] << project.issues.where(status_id: mistaken_status.id).where("closed_on >= ? and closed_on <= ?", month.beginning_of_month, month.end_of_month).count
    end

    @@graph_data = render json: {
      labels: @labels.map { |date| I18n.l(date.to_date, format: :month_year) },
      datasets: @datasets
    }.to_json

    @@graph_data
  end

  protected

  def exclude_statuses
    return "" if @widget.config[:exclude_statuses].blank?
    @exclude_statuses ||= @widget.config[:exclude_statuses].split(/\s+/)
  end

  def set_customer_by_issue_value
    @customers = Issue.group_customers_by_cnpj_cpf
                      .find_values
                      .find_social_name
                      .where('due_date is not null')
                      .select('customer_field.value cnpj_cpf, max(social_name.value) social_name,
                              sum(value_field.value) as total_value')
                      .order('total_value DESC')
                      .limit(10)
                      .map(&:cnpj_cpf)
  end

  def set_customer_by_issue_number
    @customers = Issue.joins(:custom_values)
            .joins('INNER JOIN `custom_values` social_name ON social_name.`customized_id` = `issues`.`id`
                    AND social_name.`customized_type` = \'Issue\'')
            .where(social_name: {custom_field_id: Setting.plugin_redmine_gestor_chamadas[:social_name]})
            .where(custom_values: {custom_field_id: Setting.plugin_redmine_gestor_chamadas[:customer_field]})
            .group('case
                      when (length(custom_values.value) = 14)
                        then mid(custom_values.value, 1, 8)
                      else
                        custom_values.value
                      end')
            .select('(case
                      when (length(custom_values.value) = 14)
                        then mid(custom_values.value, 1, 8)
                      else
                        custom_values.value
                      end) cnpj_cpf, max(social_name.value) social_name, count(issues.id) count_all')
            .where(project_id: [1, 32, 33])
            .order('count_all desc')
            .limit(10)
  end

  def top_customers_by_issues(issues, n = 10)
    issues.eager_load([:customer])
            .where('contacts.id is not null')
            .group('contacts.company')
            .order('count_id desc, contacts.company')
            .limit(n)
            .count
            .keys
  end

  def reopened_issues
    Issue.joins(journals: :details)
          .joins('JOIN issue_statuses old_status ON journal_details.property = \'attr\' and journal_details.old_value = old_status.id')
          .joins('JOIN issue_statuses new_status ON journal_details.property = \'attr\' and journal_details.value = new_status.id')
          .where('old_status.is_closed = true')
          .where('new_status.is_closed = false')
  end

end
