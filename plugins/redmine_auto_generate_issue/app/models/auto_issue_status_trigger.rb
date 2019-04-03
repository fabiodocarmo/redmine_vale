class AutoIssueStatusTrigger < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :tracker
  belongs_to :status_to, class_name: 'IssueStatus'
  belongs_to :status_from, class_name: 'IssueStatus'

  belongs_to :status_auto_issue, class_name: 'AutoIssue'
  delegate :build_issue, to: :status_auto_issue
end
