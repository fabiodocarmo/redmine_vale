class AddFlagStatusArchivable < ActiveRecord::Migration
  def change
    add_column :issue_statuses, :archivable, :boolean, null: true

    IssueStatus.where(is_closed: true).update_all(archivable: true)
  end
end
