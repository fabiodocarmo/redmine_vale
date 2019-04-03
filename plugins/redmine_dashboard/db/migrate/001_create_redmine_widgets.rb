class CreateRedmineWidgets < ActiveRecord::Migration
  def change
    create_table :redmine_widgets do |t|
      t.string :name_id
      t.references :role
      t.string :source_plugin
    end
  end
end
