class CreateWidgetCustomFieldRelation < ActiveRecord::Migration
  def self.up
    create_table :custom_fields_redmine_widgets, :id => false do |t|
      t.integer :custom_field_id, :default => 0, :null => false
      t.integer :redmine_widget_id, :default => 0, :null => false
    end
  end

  def self.down
    drop_table :custom_fields_redmine_widgets
  end
end
