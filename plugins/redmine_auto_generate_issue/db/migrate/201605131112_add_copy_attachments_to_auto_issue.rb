class AddCopyAttachmentsToAutoIssue < ActiveRecord::Migration
  def change
    add_column :auto_issues, :copy_attachments, :boolean
  end
end
