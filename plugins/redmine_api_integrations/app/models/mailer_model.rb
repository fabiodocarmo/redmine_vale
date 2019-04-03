require 'roadie'

class MailerModel < ActionMailer::Base
  layout 'mailer'
  helper :application
  helper :issues
  helper :custom_fields

  include Redmine::I18n
  include Roadie::Rails::Automatic
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def self.default_url_options
    options = {:protocol => Setting.protocol}
    if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
      host, port, prefix = $2, $4, $5
      options.merge!({
        :host => host, :port => port, :script_name => prefix
      })
    else
      options[:host] = Setting.host_name
    end
    options
  end

  # Returns the textual representation of a single journal detail
  def self.detail_to_string(detail)
    value = 0
    old_value = 0
    string = ""
    case detail.property
    when 'attr'
      field = detail.prop_key.to_s.gsub(/\_id$/, "")
      label = l(("field_" + field).to_sym)
      case detail.prop_key
      when 'due_date', 'start_date'
        value = format_date(detail.value.to_date) if detail.value
        old_value = format_date(detail.old_value.to_date) if detail.old_value

      when 'project_id', 'status_id', 'tracker_id', 'assigned_to_id',
            'priority_id', 'category_id', 'fixed_version_id'
        value = MailerModel.find_name_by_reflection(field, detail.value)
        old_value = MailerModel.find_name_by_reflection(field, detail.old_value)

      when 'estimated_hours'
        value = l_hours_short(detail.value.to_f) unless detail.value.blank?
        old_value = l_hours_short(detail.old_value.to_f) unless detail.old_value.blank?

      when 'parent_id'
        value = "##{detail.value}" unless detail.value.blank?
        old_value = "##{detail.old_value}" unless detail.old_value.blank?
      end

      string = "#{l(:the_field)} #{label} #{l(:has_been_changed_from)} #{old_value} #{l(:value_to)} #{value}"
    when 'cf'
      custom_field = detail.custom_field
      if custom_field
        label = custom_field.name
        value = detail.value if detail.value
        old_value = detail.old_value if detail.old_value

        string = "#{l(:the_field)} #{label} #{l(:has_been_changed_from)} #{old_value} #{l(:value_to)} #{value}"
      end
    when 'relation'
      string = l(:issue_copy_to)
    end
    return string
  end

  # Find the name of an associated record stored in the field attribute
  def self.find_name_by_reflection(field, id)
    unless id.present?
      return nil
    end
    @detail_value_name_by_reflection ||= Hash.new do |hash, key|
      association = Issue.reflect_on_association(key.first.to_sym)
      name = nil
      if association
        record = association.klass.find_by_id(key.last)
        if record
          name = record.name.force_encoding('UTF-8')
        end
      end
      hash[key] = name
    end
    @detail_value_name_by_reflection[[field, id]]
  end

  # Builds a mail for notifying to_users and cc_users about an issue update
  def issue_edit(journal, to_users, cc_users)
    issue = journal.journalized
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id journal
    references issue
    @author = User.find(journal.user_id)
    s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
    s << issue.subject
    @issue = issue
    @users = to_users + cc_users
    @journal = journal
    @journal_details = journal.visible_details(@users.first)
    @issue_url = "#{Setting.plugin_redmine_api_integrations[:scp_host]}/#{issue.id}"
    mail :to => to_users,
      :cc => cc_users,
      :subject => s
  end

  # Notifies users about an issue update
  def self.deliver_issue_edit(journal)
    issue = journal.journalized.reload
    to = Array(issue.author)
    cc = journal.notified_watchers - to
    journal.each_notification(to + cc) do |users|
      issue.each_notification(users) do |users2|
        MailerModel.issue_edit(journal, to & users2, cc & users2).deliver
      end
    end
  end

  def test_email(user)
    set_language_if_valid(user.language)
    @url = url_for(:controller => 'welcome')
    mail :to => user.mail,
      :subject => 'Redmine test'
  end

  # Sends reminders to issue assignees
  # Available options:
  # * :days     => how many days in the future to remind about (defaults to 7)
  # * :tracker  => id of tracker for filtering issues (defaults to all trackers)
  # * :project  => id or identifier of project to process (defaults to all projects)
  # * :users    => array of user/group ids who should be reminded
  # * :version  => name of target version for filtering issues (defaults to none)
  def self.reminders(options={})
    days = options[:days] || 7
    project = options[:project] ? Project.find(options[:project]) : nil
    tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil
    target_version_id = options[:version] ? Version.named(options[:version]).pluck(:id) : nil
    if options[:version] && target_version_id.blank?
      raise ActiveRecord::RecordNotFound.new("Couldn't find Version with named #{options[:version]}")
    end
    user_ids = options[:users]

    scope = Issue.open.where("#{Issue.table_name}.assigned_to_id IS NOT NULL" +
      " AND #{Project.table_name}.status = #{Project::STATUS_ACTIVE}" +
      " AND #{Issue.table_name}.due_date <= ?", days.day.from_now.to_date
    )
    scope = scope.where(:assigned_to_id => user_ids) if user_ids.present?
    scope = scope.where(:project_id => project.id) if project
    scope = scope.where(:fixed_version_id => target_version_id) if target_version_id.present?
    scope = scope.where(:tracker_id => tracker.id) if tracker
    issues_by_assignee = scope.includes(:status, :assigned_to, :project, :tracker).
                              group_by(&:assigned_to)
    issues_by_assignee.keys.each do |assignee|
      if assignee.is_a?(Group)
        assignee.users.each do |user|
          issues_by_assignee[user] ||= []
          issues_by_assignee[user] += issues_by_assignee[assignee]
        end
      end
    end

    issues_by_assignee.each do |assignee, issues|
      reminder(assignee, issues, days).deliver if assignee.is_a?(User) && assignee.active?
    end
  end

  # Activates/desactivates email deliveries during +block+
  def self.with_deliveries(enabled = true, &block)
    was_enabled = ActionMailer::Base.perform_deliveries
    ActionMailer::Base.perform_deliveries = !!enabled
    yield
  ensure
    ActionMailer::Base.perform_deliveries = was_enabled
  end

  # Sends emails synchronously in the given block
  def self.with_synched_deliveries(&block)
    saved_method = ActionMailer::Base.delivery_method
    if m = saved_method.to_s.match(%r{^async_(.+)$})
      synched_method = m[1]
      ActionMailer::Base.delivery_method = synched_method.to_sym
      ActionMailer::Base.send "#{synched_method}_settings=", ActionMailer::Base.send("async_#{synched_method}_settings")
    end
    yield
  ensure
    ActionMailer::Base.delivery_method = saved_method
  end

  def mail(headers={}, &block)
    headers.reverse_merge! 'X-Mailer' => 'Redmine',
            'X-Redmine-Host' => Setting.host_name,
            'X-Redmine-Site' => Setting.app_title,
            'X-Auto-Response-Suppress' => 'All',
            'Auto-Submitted' => 'auto-generated',
            'From' => Setting.mail_from,
            'List-Id' => "<#{Setting.mail_from.to_s.gsub('@', '.')}>"

    # Replaces users with their email addresses
    [:to, :cc, :bcc].each do |key|
      if headers[key].present?
        headers[key] = self.class.email_addresses(headers[key])
      end
    end

    # Removes the author from the recipients and cc
    # if the author does not want to receive notifications
    # about what the author do
    if @author && @author.logged? && @author.pref.no_self_notified
      addresses = @author.mails
      headers[:to] -= addresses if headers[:to].is_a?(Array)
      headers[:cc] -= addresses if headers[:cc].is_a?(Array)
    end

    if @author && @author.logged?
      redmine_headers 'Sender' => @author.login
    end

    # Blind carbon copy recipients
    if Setting.bcc_recipients?
      headers[:bcc] = [headers[:to], headers[:cc]].flatten.uniq.reject(&:blank?)
      headers[:to] = nil
      headers[:cc] = nil
    end

    if @message_id_object
      headers[:message_id] = "<#{self.class.message_id_for(@message_id_object)}>"
    end
    if @references_objects
      headers[:references] = @references_objects.collect {|o| "<#{self.class.references_for(o)}>"}.join(' ')
    end

    m = if block_given?
      super headers, &block
    else
      super headers do |format|
        format.text
        format.html unless Setting.plain_text_mail?
      end
    end
    set_language_if_valid @initial_language

    m
  end

  def initialize(*args)
    @initial_language = current_language
    set_language_if_valid Setting.default_language
    super
  end

  def self.deliver_mail(mail)
    #return false if mail.to.blank? && mail.cc.blank? && mail.bcc.blank?
    begin
      # Log errors when raise_delivery_errors is set to false, Rails does not
      mail.raise_delivery_errors = true
      super
    rescue Exception => e
      if ActionMailer::Base.raise_delivery_errors
        raise e
      else
        Rails.logger.error "Email delivery error: #{e.message}"
      end
    end
  end

  def self.method_missing(method, *args, &block)
    if m = method.to_s.match(%r{^deliver_(.+)$})
      ActiveSupport::Deprecation.warn "Mailer.deliver_#{m[1]}(*args) is deprecated. Use Mailer.#{m[1]}(*args).deliver instead."
      send(m[1], *args).deliver
    else
      super
    end
  end

  # Returns an array of email addresses to notify by
  # replacing users in arg with their notified email addresses
  #
  # Example:
  #   Mailer.email_addresses(users)
  #   => ["foo@example.net", "bar@example.net"]
  def self.email_addresses(arg)
    arr = Array.wrap(arg)
    mails = arr.reject {|a| a.is_a? Principal}
    users = arr - mails
    if users.any?
      mails += EmailAddress.
        where(:user_id => users.map(&:id)).
        where("is_default = ? OR notify = ?", true, true).
        pluck(:address)
    end
    mails
  end

  # Appends a Redmine header field (name is prepended with 'X-Redmine-')
  def redmine_headers(h)
    h.each { |k,v| headers["X-Redmine-#{k}"] = v.to_s }
  end

  def self.token_for(object, rand=true)
    timestamp = object.send(object.respond_to?(:created_on) ? :created_on : :updated_on)
    hash = [
      "redmine",
      "#{object.class.name.demodulize.underscore}-#{object.id}",
      timestamp.strftime("%Y%m%d%H%M%S")
    ]
    if rand
      hash << Redmine::Utils.random_hex(8)
    end
    host = Setting.mail_from.to_s.strip.gsub(%r{^.*@|>}, '')
    host = "#{::Socket.gethostname}.redmine" if host.empty?
    "#{hash.join('.')}@#{host}"
  end

  # Returns a Message-Id for the given object
  def self.message_id_for(object)
    token_for(object, true)
  end

  # Returns a uniq token for a given object referenced by all notifications
  # related to this object
  def self.references_for(object)
    token_for(object, false)
  end

  def message_id(object)
    @message_id_object = object
  end

  def references(object)
    @references_objects ||= []
    @references_objects << object
  end

  def mylogger
    Rails.logger
  end
end
