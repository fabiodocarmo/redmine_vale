class ExportToEmailJob
  include QueriesHelper
  include SortHelper
  include Redmine::I18n
  include Redmine::Pagination

  attr_accessor :params, :project, :user_id

  def initialize(params, session, project, user_id)
    @params = params
    @session = session
    @project = project
    @user_id = user_id
  end

  def csv_to_mail
    User.current = User.find(@user_id)
    issues_list = export_csv(@params, @session, @project)
    send_email(issues_list)
  end
  handle_asynchronously :csv_to_mail

  def send_email(issues_list)
    MailerExport.send_issues_export(issues_list, @user_id).deliver
  end

  def export_csv(params = {}, session = {},project)
    @project = Project.find(project)

    retrieve_query

    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update_self(@query.sortable_columns,params)

    @query.sort_criteria = sort_criteria.to_a

    @limit = Setting.issues_export_limit.to_i
    if params[:columns] == 'all'
      @query.column_names = @query.available_inline_columns.map(&:name)
    end

    @issue_count = @query.issue_count
    @issue_pages = Paginator.new @issue_count, @limit
    @offset ||= @issue_pages.offset
    @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                            :order => sort_clause,
                            :offset => @offset,
                            :limit => @limit)

    query_to_csv(@issues, @query, params)
  end

  def session
    session = ActiveSupport::HashWithIndifferentAccess.new(@session)
  end

  def query_to_csv(items, query, options={})
    encoding = I18n.t(:general_csv_encoding)
    #columns = (options[:columns] == 'all' ? query.available_inline_columns : query.inline_columns)
    columns = query.available_inline_columns
    query.available_block_columns.each do |column|
      if options[column.name].present?
        columns << column
      end
    end

    if Redmine::VERSION::MAJOR >= 3
      export = Redmine::Export::CSV.generate { |csv| generate_csv(csv, columns, encoding, items) }
    else
      export = FCSV.generate(:col_sep => I18n.t(:general_csv_separator)) { |csv| generate_csv(csv, columns, encoding, items) }
    end

    export
  end

 def generate_csv(csv, columns, encoding, items)
   # csv header fields
   csv << columns.collect {|c| Redmine::CodesetUtil.from_utf8(c.caption.to_s, encoding) }
   # csv lines
   items.each do |item|
     csv << columns.collect {|c| Redmine::CodesetUtil.from_utf8(csv_content(c, item), encoding) }
   end
 end

  def action_name
    'index'
  end

  def api_request?(params={})
    %w(xml json).include? params[:format]
  end

  # Updates the sort state. Call this in the controller prior to calling
  # sort_clause.
  # - criteria can be either an array or a hash of allowed keys
  #
  def sort_update_self(criteria, params={}, sort_name=nil)
    @sort_criteria = SortCriteria.new
    @sort_criteria.available_criteria = criteria
    @sort_criteria.from_param(params[:sort])
    @sort_criteria.criteria = @sort_default if @sort_criteria.empty?
  end

  def format_object(object, html=true, &block)
    if block_given?
      object = yield object
    end
    case object.class.name
    when 'Array'
      object.map {|o| format_object(o, html)}.join(', ').html_safe
    when 'Time'
      format_time(object)
    when 'Date'
      format_date(object)
    when 'Fixnum'
      object.to_s
    when 'Float'
      sprintf "%.2f", object
    when 'User'
      html ? link_to_user(object) : object.to_s
    when 'Project'
      html ? link_to_project(object) : object.to_s
    when 'Version'
      html ? link_to_version(object) : object.to_s
    when 'TrueClass'
      l(:general_text_Yes)
    when 'FalseClass'
      l(:general_text_No)
    when 'Issue'
      object.visible? && html ? link_to_issue(object) : "##{object.id}"
    when 'CustomValue', 'CustomFieldValue'
      if object.custom_field
        f = object.custom_field.format.formatted_custom_value(self, object, html)
        if f.nil? || f.is_a?(String)
          f
        else
          format_object(f, html, &block)
        end
      else
        object.value.to_s
      end
    else
      html ? h(object) : object.to_s
    end
  end
end
