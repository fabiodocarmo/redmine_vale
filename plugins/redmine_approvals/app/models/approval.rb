class Approval < ActiveRecord::Base
  unloadable

  scope :atual_approvals, lambda { |issue| where(project_id: issue.project_id,
                                            tracker_id: issue.tracker_id,
                                            group_id: issue.assigned_to)
                                          .where(use_custom_field_where(issue)) }

  scope :issue_approvals, lambda { |issue| where(project_id: issue.project_id,
                                             tracker_id: issue.tracker_id,
                                             status_from_id: issue.status_id_was,
                                             status_to_id: issue.status_id)
                                          .where(use_custom_field_where(issue)) }

  scope :next_approvals, lambda { |issue, level|
    where(project_id: issue.project_id,
          tracker_id: issue.tracker_id)
          .where('level > ?', level)
          .where(use_custom_field_where(issue))
  }

  SIGNS = {
  	greater_than: 'Maior que',
  	less_than: 'Menor que',
  	equal_to: 'Igual que',
  	greater_than_or_equal_to: 'Maior ou Igual que',
  	less_than_or_equal_to: 'Menor ou Igual que',
    any: 'Qualquer'
  }.with_indifferent_access


  attr_protected :project_id, :tracker_id, :group_id,
                 :custom_field_id, :sign, :value,
                 :level, :level_below, as: :admin

  belongs_to :project
  belongs_to :tracker
  belongs_to :custom_field
  belongs_to :second_custom_field, class_name: 'IssueCustomField'
  belongs_to :status_from, class_name: 'IssueStatus'
  belongs_to :status_to  , class_name: 'IssueStatus'
  belongs_to :group

  def self.atual_approval(issue)
    self.atual_approvals(issue).first
  end

  def self.verify_approval_is_required(issue)
    if issue.status_id == Setting.plugin_redmine_approvals[:approval_status].to_i
      atual_approval = Approval.atual_approval(issue)

      if atual_approval && next_approval = get_next_approval(issue, atual_approval)
        return approval_group(next_approval) if is_approval_required?(issue, next_approval)
      end
    else
      return get_first_approval(issue)
    end

    return [nil, nil]
  end

  private

  def self.get_next_approval(issue, atual_approval)
    level = atual_approval.level

    approvals   = Approval.next_approvals(issue, level).order('level asc')
    my_approval = get_my_approval(approvals)

    approvals.reject { |a| my_approval && a.level <= my_approval.level }.first
  end

  def self.get_first_approval(issue)
    if approvals = Approval.issue_approvals(issue).order('level desc')
      approvals.each do |approval|
        break if approval.group.users.include? User.current
        return first_approval_group(issue, approval, approvals) if is_approval_required?(issue, approval)
      end
    end

    [nil, nil]
  end

  def self.first_approval_group(issue, approval, approvals)
    my_approval    = get_my_approval(approvals)
    first_approval = approvals.select { |a| a.level == approval.level - approval.level_below }.first

    if my_approval && my_approval.level >= first_approval.level
      approval_group(approvals.select { |a| a.level == my_approval.level + 1 && a.level <= approval.level }.first)
    else
      approval_group(first_approval)
    end
  end

  def self.get_my_approval(approvals)
    my_approval = nil
    approvals.each do |a|
      ((my_approval = a) && break) if a.group.users.include? User.current
    end
    my_approval
  end

  def self.is_approval_required?(issue, approval)
    issue_value, approval_value = values(issue, approval)
    sign =  approval.sign.to_sym

    return ((sign == :greater_than && issue_value > approval_value)      ||
    (sign == :less_than && issue_value < approval_value)                 ||
    (sign == :less_than_or_equal_to && issue_value <= approval_value)    ||
    (sign == :equal_to && issue_value == approval_value)                 ||
    (sign == :greater_than_or_equal_to && issue_value >= approval_value) ||
    (sign == :any))
  end

  def self.values(issue, approval)
    type = approval.custom_field.field_format

    issue_value    = issue.custom_field_value(approval.custom_field)
    approval_value = approval.value

    case type
    when "int"
      [issue_value.to_i, approval_value.to_i]
    when "float"
      [issue_value.to_f, approval_value.to_f]
    else
      [issue_value, approval_value]
    end
  end

  def self.approval_group(approval)
    if approval
      [approval.group.id, Setting.plugin_redmine_approvals[:waiting_approval_status]]
    else
      [nil, nil]
    end
  end

  def self.use_custom_field_where(issue)
    @use_custom_field_where = "use_second_custom_field = false or ("
    @use_custom_field_where += create_query_for_only_one_custom_field(issue.custom_field_values, issue)
    @use_custom_field_where += "1 = 2)"
    @use_custom_field_where
  end

  def self.create_query_for_only_one_custom_field(custom_values, issue)
    custom_values.map do |cv|
      if cv.value.is_a? Array
        ActiveRecord::Base.send(:sanitize_sql_array, ["(second_custom_field_id = ? and second_custom_field_value in (?)) or ", cv.custom_field_id, cv.value])
      else
        ActiveRecord::Base.send(:sanitize_sql_array, ["(second_custom_field_id = ? and second_custom_field_value = ?) or ", cv.custom_field_id, cv.value.to_s])
      end
    end.join('')
  end
end
