class CreateAutoIssues < ActiveRecord::Migration
  def change
    create_table :auto_issues do |t|
      t.references :project, index: true
      t.references :tracker, index: true
      t.references :issue_status, index: true
      t.references :principal, index: true

      t.text :watcher_ids

      t.string :title
      t.text :description
      t.string :type
    end
  end
end
