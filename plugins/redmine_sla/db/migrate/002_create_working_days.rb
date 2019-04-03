class CreateWorkingDays < ActiveRecord::Migration
  def change
    create_table :working_days do |t|
      t.references :office_hour, index: true, foreign: true
      t.string :week_day
      t.time :start_time
      t.time :end_time
      t.string :timezone
    end
  end
end
