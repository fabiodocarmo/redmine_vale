class VisibilityReport < ActiveRecord::Base

  belongs_to :tracker, :class_name => 'Tracker'
  belongs_to :user, :class_name => 'User'
  belongs_to :issue, :class_name => 'Issue'
  belongs_to :hierarchy, :class_name => 'Hierarchy'

  attr_accessible :id,
  :created_at,
  :supplier_social_name,
  :supplier_cnpj,
  :classification,
  :area,
  :total_aging,
  :phase_aging,
  :sent_number,
  :user_id,
  :tracker_id,
  :issue_id,
  :hierarchy_id

  def to_s
    issue.subject.to_s
  end
end
