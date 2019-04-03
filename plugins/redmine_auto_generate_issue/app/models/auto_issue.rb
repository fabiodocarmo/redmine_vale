class AutoIssue < ActiveRecord::Base
  unloadable

  serialize :watcher_ids, Array

  belongs_to :author, class_name: 'User'
  belongs_to :project
  belongs_to :tracker
  belongs_to :issue_status
  belongs_to :principal

  has_many :custom_values, as: :customized
  accepts_nested_attributes_for :custom_values, reject_if: :all_blank, allow_destroy: true


  def self.trigger_types
    %w(ScheduleAutoIssue StatusAutoIssue RecurrentAutoIssue AttachmentAutoIssue)
  end

  def build_issue(previous_issue=Issue.new)
    previous_title       = previous_issue.subject
    previous_description = previous_issue.description
    previous_project_id  = previous_issue.project_id
    previous_tracker_id  = previous_issue.tracker_id


    new_issue_params = {
      subject:     (title.blank?       ? previous_title       : title),
      description: (description.blank? ? previous_description : description),
      project_id:  (project_id.blank?  ? previous_project_id  : project_id),
      tracker_id:  (tracker_id.blank?  ? previous_tracker_id  : tracker_id),
      status_id: issue_status_id,
      start_date: Time.zone.now
    }

    issue                  = Issue.new(new_issue_params)
    issue.assigned_to      = principal

    if watcher_ids.is_a?(Array)
      user_ids = watcher_ids.uniq
      user_ids = User.joins("LEFT JOIN groups_users on groups_users.user_id = #{User.table_name}.id").active.where("groups_users.group_id in (:user_ids) or #{User.table_name}.id in (:user_ids)", user_ids: watcher_ids + [0]).uniq.sorted.map(&:id)
      issue.watcher_user_ids = user_ids
    end

    if previous_issue.custom_values.blank?
      issue.custom_fields = custom_values.map { |cv| {id: cv.custom_field_id, value: cv.value} }
    else
      issue.custom_fields = previous_issue.custom_values.map { |cv| {id: cv.custom_field_id, value: cv.value} } | custom_values.map { |cv| {id: cv.custom_field_id, value: cv.value} }
    end

    if copy_attachments
      issue.attachments = previous_issue.attachments.map do |attachement|
        attachement.copy(container: issue)
      end
    end

    issue.author = author || previous_issue.author || AnonymousUser.first
    issue
  end
end
