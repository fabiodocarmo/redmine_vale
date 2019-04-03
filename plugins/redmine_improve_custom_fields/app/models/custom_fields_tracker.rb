class CustomFieldsTracker < ActiveRecord::Base
  default_scope -> { order('position ASC') }

  attr_protected :tracker_id, :custom_field_id, :position, as: :admin

  belongs_to :tracker
  belongs_to :custom_field
end
