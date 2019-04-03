class CreateSqlReports < ActiveRecord::Migration
  def change
    create_table :sql_reports do |t|
      t.string :name
      t.text :sql
      t.text :filters
    end
  end
end
