class AutoIssueRecurrentTrigger < ActiveRecord::Base
  unloadable

  belongs_to :recurrent_auto_issue, class_name: 'AutoIssue'
  delegate :build_issue, to: :recurrent_auto_issue
end
