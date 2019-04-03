class AtribuicaoAutomatica < ActiveRecord::Base
  unloadable

  scope :find_by_issue, lambda { |issue|
    where('(project_id     = ? or all_projects    = true)', issue.project_id).
    where('(tracker_id     = ? or all_trackers    = true)', issue.tracker_id).
    where('(status_from_id = ? or (status_from_id is NULL and ? is NULL) or all_status_from = true)', issue.status_id_was, issue.status_id_was).
    where(status_to_id: issue.status_id).
    where(use_custom_field_where(issue))
  }

  scope :find_open_redistribute_by_issue, lambda { |issue|
    where('(project_id = ? or all_projects = true)', issue.project_id).
    where('(tracker_id = ? or all_trackers = true)', issue.tracker_id).
    where(status_to_id: issue.status_id).
    where(use_custom_field_where(issue)).where("redistribute = 'open'")
  }

  attr_protected :project_id, :tracker_id, :group_id,
                 :status_from_id, :status_to_id, :redistribute,
                 :use_custom_field, :custom_field_id, :custom_field_value,
                 :second_custom_field_id, :second_custom_field_id, :weekend_group_id,
                 :issue_user_custom_field_id,
                 as: :admin

  belongs_to :project
  belongs_to :tracker
  belongs_to :group
  belongs_to :status_from, class_name: 'IssueStatus'
  belongs_to :status_to  , class_name: 'IssueStatus'
  belongs_to :custom_field
  belongs_to :second_custom_field, class_name: 'CustomField'
  belongs_to :user_custom_field, class_name: 'CustomField'
  belongs_to :issue_user_custom_field, class_name: 'CustomField'
  belongs_to :weekend_group, class_name: 'Group'

  WATCHER_REDISTRIBUTE_TYPE = [:watcher, :assigned_to_watcher, :issue_user_custom_field_field_watcher]
  REDISTRIBUTE_TYPE = {
    workload: l(:redistribute_type_workload),
    round: l(:redistribute_type_round),
    author: l(:redistribute_type_author),
    watcher: l(:redistribute_type_watcher),
    assigned_to_watcher: l(:redistribute_type_assigned_to_watcher),
    open: l(:redistribute_type_open),
    me: l(:redistribute_type_me),
    author_manager: l(:redistribute_type_author_manager),
    assigned_to_manager: l(:redistribute_type_assigned_to_manager),
    current_user_manager: l(:redistribute_type_current_user_manager),
    custom_field_user_manager: l(:redistribute_type_custom_field_user_manager)
  }.with_indifferent_access

  def workload_redistribute(_issue)
    if self.assign_group.users.any?
      User.joins('LEFT JOIN issues on users.id = issues.assigned_to_id and issues.closed_on is null')
                                 .where(id: self.assign_group.users.where('status != ?', Principal::STATUS_LOCKED).map(&:id))
                                 .group('users.id').order('count_issues_id ASC')
                                 .count('issues.id').first[0]
    else
      self.assign_group.id
    end
  end

  def round_redistribute(_issue)
    users = assign_group.users.where('status != ?', Principal::STATUS_LOCKED)

    if users.length > 0
      round_redistribute = RoundRedistribute.where(group_id: assign_group.id).first_or_initialize
      round_redistribute.times += 1

      users[round_redistribute.times%users.length].id
    else
      assign_group.id
    end
  end

  def author_redistribute(issue)
    issue.author_id
  end

  def open_redistribute(issue)
    assign_group.id
  end

  def me_redistribute(_issue)
    User.current.id
  end

  def author_manager_redistribute(issue)
    fetch_manager(issue.author)
  end

  def assigned_to_manager_redistribute(issue)
    issue.assigned_to.is_a?(Group) ? assign_group.id : fetch_manager(issue.assigned_to)
  end

  def current_user_manager_redistribute(_issue)
    fetch_manager(User.current)
  end

  def assign_group
    weekend_group_id && Time.zone.now.wday.to_s.in?(Setting[:non_working_week_days]) ? weekend_group : group
  end

  def watcher_redistribute(_issue)
    self.group.users.status(User::STATUS_ACTIVE).map { |us| us.id }
  end

  def assigned_to_watcher_redistribute(issue)
    if issue.assigned_to.is_a?(Group)
      issue.assigned_to.users.status(User::STATUS_ACTIVE).map { |us| us.id }
    elsif issue.assigned_to.active?
      [issue.assigned_to.try(:id)]
    else
      []
    end
  end

  def custom_field_user_manager_redistribute(issue)
    if user = fetch_user_from_issue_user_custom_field(issue)
      fetch_manager(user)
    else
      assign_group.id
    end
  end

  def issue_user_custom_field_field_watcher_redistribute(issue)
    [fetch_user_from_issue_user_custom_field(issue).try(:id)]
  end

  private

  def fetch_user_from_issue_user_custom_field(issue)
    User.find_by_id(issue.custom_field_value(self.issue_user_custom_field_id))
  end

  def fetch_manager(user)
    User.find_by_login(user.custom_field_value(self.user_custom_field)).try(:id) || assign_group.id
  end

  def self.use_custom_field_where(issue)
    @use_custom_field_where = "use_custom_field = false or ("

    @use_custom_field_where += create_query_for_only_one_custom_field(issue.custom_field_values, issue)

    if Setting.plugin_redmine_auto_assign['two_custom_fields_available']
      @use_custom_field_where += create_query_for_two_custom_field(issue.custom_field_values, issue)
    end

    @use_custom_field_where += "1 = 2)"
    @use_custom_field_where
  end

  def self.create_query_for_only_one_custom_field(custom_values, issue)
    custom_values.map do |cv|
      if cv.value.is_a? Array
        ActiveRecord::Base.send(:sanitize_sql_array, ["(custom_field_id = ? and custom_field_value in (?) and second_custom_field_id is null) or ", cv.custom_field_id, cv.value])
      else
        ActiveRecord::Base.send(:sanitize_sql_array, ["(custom_field_id = ? and custom_field_value = ? and second_custom_field_id is null) or ", cv.custom_field_id, cv.value.to_s])
      end
    end.join('')
  end

  def self.create_query_for_two_custom_field(custom_values, issue)
    custom_values.permutation(2).map do |cv1, cv2|
      if cv1.value.is_a?(Array) && cv2.value.is_a?(Array)
        ActiveRecord::Base.send(:sanitize_sql_array, ["(custom_field_id = ? and custom_field_value in (?) and second_custom_field_id = ? and second_custom_field_value in (?) ) or ", cv1.custom_field_id, cv1.value, cv2.custom_field_id, cv2.value])
      elsif cv1.value.is_a?(Array) && !cv2.value.is_a?(Array)
        ActiveRecord::Base.send(:sanitize_sql_array, ["(custom_field_id = ? and custom_field_value in (?) and second_custom_field_id = ? and second_custom_field_value = ?) or ", cv1.custom_field_id, cv1.value, cv2.custom_field_id, cv2.value.to_s])
      elsif !cv1.value.is_a?(Array) && cv2.value.is_a?(Array)
        ActiveRecord::Base.send(:sanitize_sql_array, ["(custom_field_id = ? and custom_field_value = ?    and second_custom_field_id = ? and second_custom_field_value in (?) ) or ", cv1.custom_field_id, cv1.value.to_s, cv2.custom_field_id, cv2.value])
      else
        ActiveRecord::Base.send(:sanitize_sql_array, ["(custom_field_id = ? and custom_field_value = ?    and second_custom_field_id = ? and second_custom_field_value = ?) or ", cv1.custom_field_id, cv1.value.to_s, cv2.custom_field_id, cv2.value.to_s])
      end
    end.join('')
  end
end
