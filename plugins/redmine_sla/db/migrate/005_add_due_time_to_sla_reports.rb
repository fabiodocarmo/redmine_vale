class AddDueTimeToSlaReports < ActiveRecord::Migration
  def change
    add_column :sla_reports, :due_time, :datetime
  end
end
