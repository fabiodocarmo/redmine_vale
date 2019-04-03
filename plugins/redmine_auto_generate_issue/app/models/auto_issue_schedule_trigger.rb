class AutoIssueScheduleTrigger < ActiveRecord::Base
  unloadable

  belongs_to :schedule_auto_issue, class_name: 'AutoIssue'
  delegate :build_issue, to: :schedule_auto_issue
end
