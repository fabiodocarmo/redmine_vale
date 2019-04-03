class AddDashboardWidgetsIdToRedmineWidgets < ActiveRecord::Migration
  def change
    add_column :redmine_widgets, :dashboard_widget_id, :integer
    add_index :redmine_widgets, :dashboard_widget_id

    remove_column :redmine_widgets, :role_id
  end
end
