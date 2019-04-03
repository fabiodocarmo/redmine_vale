# encoding: UTF-8

class GestorChamadosTicketsController < ApplicationController
  unloadable

  layout 'new_ticket'

  skip_before_filter :check_if_login_required
  skip_before_filter :verify_authenticity_token

  before_filter :find_project, only: [:new, :create]
  before_filter :check_for_default_issue_status, only: [:new]
  before_filter :build_new_issue_from_params, only: [:new]
  before_filter :show_faq, only: [:new]
  before_filter :find_ticket, only: [:confirmation_ticket]

  helper :journals
  helper :projects
  include ProjectsHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :issue_relations
  include IssueRelationsHelper
  helper :watchers
  include WatchersHelper
  helper :attachments
  include AttachmentsHelper
  helper :queries
  include QueriesHelper
  helper :repositories
  include RepositoriesHelper
  helper :sort
  include SortHelper
  include IssuesHelper
  helper :timelog
  include Redmine::Export::PDF
  helper :tickets
  include TicketsHelper

  def new
    respond_to do |format|
      format.html { render action: 'new', layout: !request.xhr? }
      format.js   { render action: 'update_form' }
    end
  end

  def confirmation_ticket
    @issue = @ticket.issue

    if @issue.status_id == Setting.plugin_redmine_gestor_chamadas[:not_confirmed_status].to_i
      redirect_to gestor_chamados_projects_path, :flash => { :error => l(:expiration_date_error_message)}
      return nil
    end

    if @issue.status_id == Setting.plugin_redmine_gestor_chamadas[:waiting_status].to_i
      @issue.status = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:new_status])

      assign_to_same_custom_field
      params[:issue] = issue_to_hash(@issue)
      @issue.save!(validate: false)

      call_hook(:controller_issues_edit_after_save, { :params => params, :issue => @issue, :time_entry => TimeEntry.new, :journal => @issue.current_journal})
    end

    redirect_to(public_ticket_path(params[:id], params[:token]), notice: l(:ticket_sucessfully_created_message))
  end

  def create
    fail Exception, l(:param_ticket_should_be_set_exception) if params[:issue].blank?
    @issue = Issue.new
    @issue.project = @project

    @issue.author = AnonymousUser.first

    @issue.safe_attributes = params[:issue]

    fail Exception, l(:contact_should_have_email_exception) unless params[:helpdesk_ticket][:customer_attributes] || params[:helpdesk_ticket][:customer_attributes][:email]

    @contact   = Contact.find_by_emails([params[:helpdesk_ticket][:customer_attributes][:email]]).first
    @contact ||= Contact.new(params[:helpdesk_ticket][:customer_attributes])
    @contact.first_name = params[:helpdesk_ticket][:customer_attributes][:first_name]
    @contact.last_name  = params[:helpdesk_ticket][:customer_attributes][:last_name]

    @contact.visibility = Contact::VISIBILITY_PUBLIC
    @contact.projects << @project

    helpdesk_ticket = HelpdeskTicket.new(:from_address => @contact.primary_email,
      :to_address => '',
      :ticket_date => Time.now,
      :customer => @contact,
      :issue => @issue,
      :source => HelpdeskTicket::HELPDESK_WEB_SOURCE)

    @issue.helpdesk_ticket = helpdesk_ticket
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))

    @issue.status_id = params[:status_id].to_i
    default_priority = Setting.plugin_redmine_gestor_chamadas[:create_priority]
    fail Exception, l(:new_tickets_default_priority_exception) if default_priority.blank?
    @issue.priority_id = default_priority
    @ticket         = helpdesk_ticket
    @ticket.issue   = @issue

    @issue.contacts << @contact
    @copy_to = params[:copy_to]

    @copy_to.split(',').each do |copy_email|
      contact = Contact.find_by_emails([copy_email.strip]).first
      unless contact
        contact = Contact.new(email: copy_email.strip, first_name: copy_email.strip.split('@')[0])
        contact.visibility = Contact::VISIBILITY_PUBLIC
      end

      contact.projects << @project

      @issue.contacts << contact
    end unless @copy_to.empty?

    call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })

    if email_is_valid && @issue.save
      params[:project_id] = @project.id
      call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
      HelpdeskMailer.auto_answer(@contact, @issue).deliver

      flash[:warning] = t(:warning_deletion_unconfirmed_tickets, days: Setting.plugin_redmine_gestor_chamadas['after_days'])
      if params['submit'] == l(:button_submit)
        respond_to do |format|
          format.html do
            redirect_to public_ticket_path(@issue.helpdesk_ticket.id, @issue.helpdesk_ticket.token), notice: l(:confirmation_email_sent_message)
          end
        end
      else
        respond_to do |format|
          format.html do
            redirect_to new_gestor_chamados_ticket_path, flash: {copy_from: @ticket.id, copy_to: @copy_to, email_confirmation: params[:email_confirmation]}, notice: l(:confirmation_email_sent_message)
          end
        end
      end
    else
      @issue.valid?
      @issue.errors.delete :"helpdesk_ticket.customer.first_name"
      first_name_error = @issue.errors.delete :"contacts.first_name"

      @issue.errors[l(:first_name_error_param)] = first_name_error[0] unless first_name_error.blank?

      @issue.errors.delete :"helpdesk_ticket.customer.email"
      email_error = @issue.errors.delete :"contacts.email"
      @issue.errors[l(:email_error_param)] = email_error[0] unless email_error.blank?

      unless email_is_valid
        unless params[:helpdesk_ticket][:customer_attributes][:email] == params[:email_confirmation]
          @issue.errors[l(:confirm_email_error_param)] = l(:email_doesnt_match_error)
        end

        unless validate_email_list
          @issue.errors[l(:email_error_param)] = l(:no_permission_error)
        end
      end

      respond_to do |format|
        format.html { render action: 'new' }
      end
    end
  end

  def show_faq
    @faqs = FaqLink.where(tracker_id: @issue.tracker.id)
    @show_faq = (@faqs.length > 0 ? true : false)
  end

  protected

  def find_ticket
    @ticket = HelpdeskTicket.find(params[:id])
    render_404 unless @ticket.tokens.include?(params[:token])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def email_is_valid
    params[:helpdesk_ticket][:customer_attributes][:email] == params[:email_confirmation] && validate_email_list
  end

  def validate_email_list
    if Setting.plugin_redmine_gestor_chamadas[:email_list_behavior] == "white_list"
      return false if HelpdeskSettings[:helpdesk_blacklist, @issue.project].blank?
    else
      return true if HelpdeskSettings[:helpdesk_blacklist, @issue.project].blank?
    end

    from_addr = params[:helpdesk_ticket][:customer_attributes][:email].strip

    cond = "(" + HelpdeskSettings[:helpdesk_blacklist, @issue.project].split("\n").map{|u| u.strip unless u.blank?}.compact.join('|') + ")"

    match = from_addr.match(cond)

    if Setting.plugin_redmine_gestor_chamadas[:email_list_behavior] == "white_list"
      match
    else
      !match
    end
  end

  def check_if_login_required
    false
  end

  def assign_to_same_custom_field
    return nil unless custom_field = CustomField.where(id: Setting.plugin_redmine_gestor_chamadas[:assign_to_field]).first
    return nil unless custom_field_value = @issue.custom_value_for(custom_field)
    return nil unless same_assign_issue = Issue.joins(:custom_values).joins(:status).where('issues.id != ? and custom_values.custom_field_id = ? and custom_values.value = ? and issue_statuses.is_closed = false and project_id = ? and assigned_to_id is not null', @issue.id, custom_field.id, custom_field_value.value, @issue.project_id).first

    @issue.status      = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:doing_status]) unless Setting.plugin_redmine_gestor_chamadas[:doing_status].blank?
    @issue.assigned_to = same_assign_issue.assigned_to
  end

  def find_project
    project_id = params[:issue].try('[]', :project_id) || Setting.plugin_redmine_gestor_chamadas[:projects].first
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_for_default_issue_status
    if IssueStatus.default.nil?
      render_error l(:error_no_default_issue_status)
      return false
    end
  end

  def copy_issue_from(ticket_id)
    ticket = HelpdeskTicket.find(ticket_id)
    @issue = ticket.issue.dup

    @issue.custom_values = ticket.issue.custom_values.dup

    @issue.custom_values.each do |cv|
      @issue.custom_values.delete(cv) if cv.custom_field.dont_copy
    end

    find_statuses
    @ticket = ticket.dup
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def build_new_issue_from_params
    if flash[:copy_from]
      copy_from = flash[:copy_from]
      flash.delete(:copy_from)

      flash.delete(:copy_to)            if @copy_to = flash[:copy_to]
      flash.delete(:email_confirmation) if params[:email_confirmation] = flash[:email_confirmation]

      return copy_issue_from(copy_from)
    end

    @issue = Issue.new
    @issue.project = @project

    @issue.tracker ||= @project.trackers.where((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id]).first || @project.trackers.first

    if @issue.tracker.nil?
      render_error l(:error_no_tracker_in_project)
      return false
    end

    @issue.status      = IssueStatus.find(Setting.plugin_redmine_gestor_chamadas[:waiting_status])
    @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?
    @issue.safe_attributes = params[:issue]

    find_statuses

    @ticket = HelpdeskTicket.new
    @ticket.build_customer
    @ticket.issue = @issue



  end

  def find_statuses
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, @issue.new_record?)
    @available_watchers = @issue.watcher_users

    if @issue.project.users.count <= 20
      @available_watchers = (@available_watchers + @issue.project.users.sort).uniq
    end
  end

  def issue_to_hash(issue)
    hash = issue.attributes
    hash[:custom_field_values] = custom_field_values_to_hash(issue)
    hash
  end

  # Returns a Hash of issue custom field values
  def custom_field_values_to_hash(issue)
    hash = {}
    issue.custom_field_values.each do |custom_field_value|
      hash[custom_field_value.custom_field.id.to_s] = custom_field_value.value
    end
    hash
  end

end
