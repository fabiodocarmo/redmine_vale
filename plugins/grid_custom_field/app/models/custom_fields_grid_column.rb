class CustomFieldsGridColumn < ActiveRecord::Base
  unloadable
  attr_accessible :grid_column_id, :custom_field_id, :position

  attr_protected :grid_column_id, :custom_field_id, :position, as: :admin

  belongs_to :grid_column, class_name: "CustomField", foreign_key: "grid_column_id"
  belongs_to :custom_field, foreign_key: "custom_field_id"

end
