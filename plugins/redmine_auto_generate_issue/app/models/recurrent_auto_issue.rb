class RecurrentAutoIssue < AutoIssue
  attr_protected :author_id, :project_id, :tracker_id, :issue_status_id, :watcher_ids,
                 :principal_id, :title, :description, :custom_values_ids,
                 :auto_issue_recurrent_triggers_attributes, as: :admin

  has_many :auto_issue_recurrent_triggers, dependent: :destroy

  accepts_nested_attributes_for :auto_issue_recurrent_triggers, reject_if: :all_blank, allow_destroy: true
end
