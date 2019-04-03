class CreateSqlReportExecution < ActiveRecord::Migration
  def change
    create_table :sql_report_executions do |t|
      t.belongs_to :sql_report, index: true
      t.integer :requester_id, index: true
      t.text :filters
      t.string :status, default: 'pending'
      t.string :file_name

      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps null: false
    end
    add_foreign_key :sql_report_executions, :sql_reports
    add_foreign_key :sql_report_executions, :users, column: :requester_id
  end
end
