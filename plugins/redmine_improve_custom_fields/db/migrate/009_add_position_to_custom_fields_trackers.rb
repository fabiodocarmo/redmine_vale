class AddPositionToCustomFieldsTrackers < ActiveRecord::Migration
  def change
    add_column "#{Tracker.table_name_prefix}custom_fields_trackers#{Tracker.table_name_suffix}", :position, :integer
  end
end
