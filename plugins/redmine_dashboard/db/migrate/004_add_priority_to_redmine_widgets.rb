class AddPriorityToRedmineWidgets < ActiveRecord::Migration
  def change
    add_column :redmine_widgets, :priority, :integer
  end
end
