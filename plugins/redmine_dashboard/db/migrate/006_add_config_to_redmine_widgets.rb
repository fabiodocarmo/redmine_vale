class AddConfigToRedmineWidgets < ActiveRecord::Migration
  def change
    add_column :redmine_widgets, :config, :text
    add_column :redmine_widgets, :select_projects, :boolean
  end
end
