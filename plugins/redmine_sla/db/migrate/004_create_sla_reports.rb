class CreateSlaReports < ActiveRecord::Migration
  def change
    create_table :sla_reports do |t|
      t.references :sla, index: true, foreign_key: true
      t.references :issue, index: true, foreign_key: true
      t.references :issue_status, index: true, foreign_key: true

      t.integer :principal_id

      t.datetime :start_time
      t.datetime :end_time

      t.float :total_time  , default: 0
      t.float :working_time, default: 0

      t.boolean :discount_from_sla
    end
  end
end
