class AddAuthorToAutoIssue < ActiveRecord::Migration
  def change
    add_column :auto_issues, :author_id, :integer
    add_index  :auto_issues, [:author_id]
  end
end
