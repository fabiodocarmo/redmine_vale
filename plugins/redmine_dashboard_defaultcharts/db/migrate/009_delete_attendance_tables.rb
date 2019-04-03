class DeleteAttendanceTables < ActiveRecord::Migration
  def change
    drop_table :attendance_tables
  end
end
