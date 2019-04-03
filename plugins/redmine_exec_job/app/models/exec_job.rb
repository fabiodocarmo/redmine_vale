class ExecJob < ActiveRecord::Base
  unloadable

  scope :find_by_issue_and_callback, lambda { |issue, callback|
    where('(project_id     = ? or all_projects    = true)', issue.project_id).
    where('(tracker_id     = ? or all_trackers    = true)', issue.tracker_id).
    where('(status_from_id = ? or (status_from_id is NULL and ? is NULL) or all_status_from = true)', issue.status_id_was, issue.status_id_was).
    where(status_to_id: issue.status_id).
    where(callback_name: callback)
  }

  belongs_to :project
  belongs_to :tracker
  belongs_to :status_from, class_name: 'IssueStatus'
  belongs_to :status_to  , class_name: 'IssueStatus'

  @@jobs = []

  def self.jobs
    @@jobs
  end

  def self.register
    @@jobs << self
  end

  def perform(issue_id)
    raise NotImplementedError
  end
end
