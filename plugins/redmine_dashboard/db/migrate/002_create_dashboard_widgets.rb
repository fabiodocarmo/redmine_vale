class CreateDashboardWidgets < ActiveRecord::Migration
  def change
    create_table :dashboard_widgets do |t|
      t.string :name
      t.integer :priority
    end
  end
end
