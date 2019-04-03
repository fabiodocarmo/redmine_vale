class CreateAttendanceTables < ActiveRecord::Migration
  def change
    create_table :attendance_tables do |t|
      t.date :day
      t.integer :num
    end
  end
end
