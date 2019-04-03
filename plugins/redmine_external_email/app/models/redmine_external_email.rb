class RedmineExternalEmail < ActiveRecord::Base
  unloadable

  scope :find_by_issue, lambda { |issue|
    where('(project_id      = ? or all_projects = true)', issue.project_id)
    .where('(tracker_id     = ? or all_trackers = true)', issue.tracker_id)
    .where('(status_from_id = ? or (status_from_id is NULL and ? is NULL) or all_status_from = true)', issue.status_id_was, issue.status_id_was)
    .where(status_to_id: issue.status_id)
  }

  belongs_to :project
  belongs_to :tracker
  belongs_to :email_custom_field, class_name: 'IssueCustomField'
  belongs_to :status_from       , class_name: 'IssueStatus'
  belongs_to :status_to         , class_name: 'IssueStatus'
end
