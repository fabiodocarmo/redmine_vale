class AutoChangeStatus < ActiveRecord::Base
  unloadable


  scope :find_by_issue, lambda { |issue|
    where('(project_id     = ? or all_projects    = true)', issue.project_id)
    .where('(tracker_id     = ? or all_trackers    = true)', issue.tracker_id)
    .where('(status_from_id = ? or all_status_from = true)', issue.status_id)
    .where('(role_id in (?)     or all_roles       = true)', User.current.roles_for_project(issue.project).map(&:id))
    .where(use_custom_field_where(issue))
  }

  ACTIONS = {
              open:            l(:action_open),
              save:            l(:action_save),
              relation_closed: l(:action_relation_closed)
            }.with_indifferent_access

  attr_protected :project_id, :tracker_id, :role_id,
                 :status_from_id, :status_to_id, :action, as: :admin

  belongs_to :project
  belongs_to :tracker
  belongs_to :role
  belongs_to :custom_field
  belongs_to :status_from, class_name: 'IssueStatus'
  belongs_to :status_to, class_name: 'IssueStatus'

  private

  def self.use_custom_field_where(issue)
    @use_custom_field_where = "use_custom_field = false or ("

    @use_custom_field_where += create_query_for_only_one_custom_field(issue.custom_field_values, issue)

    @use_custom_field_where += "1 = 2)"
    @use_custom_field_where
  end

  def self.create_query_for_only_one_custom_field(custom_values, issue)
    custom_values.map do |cv|
      if cv.value.is_a? Array
        ActiveRecord::Base.send(:sanitize_sql_array, ["(custom_field_id = ? and custom_field_value in (?)) or ", cv.custom_field_id, cv.value])
      else
        ActiveRecord::Base.send(:sanitize_sql_array, ["(custom_field_id = ? and custom_field_value = ?) or ", cv.custom_field_id, cv.value.to_s])
      end
    end.join('')
  end
end
