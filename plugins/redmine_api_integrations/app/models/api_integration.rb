class ApiIntegration < ActiveRecord::Base

  scope :find_by_issue, lambda { |issue|
    where('(project_id  = ? )', issue.project_id)
    .where('(tracker_id = ? )', issue.tracker_id)
  }

  ACTIONS = {
              open:            l(:action_open),
              save:            l(:action_save),
            }.with_indifferent_access

  attr_protected :project_id, :tracker_id, :action, as: :admin

  belongs_to :project
  belongs_to :tracker

  def self.find_project_id(project_id)
    return Project.find(project_id.to_i).id
  end

  def self.find_tracker_id(tracker_id)
    return Tracker.find(tracker_id.to_i).id
  end

  def self.find_project_id_by_tracker(tracker_id)
    return ApiIntegration.where(tracker_id: tracker_id.to_i).first.project_id
  end

  def self.tracker_exists(tracker_id)
    return (ApiIntegration.where(tracker_id: tracker_id.to_i) != [])
  end

  def self.get_trackers_api_integration
    return Tracker.where(:id => ApiIntegration.all.pluck(:tracker_id))
  end
end
