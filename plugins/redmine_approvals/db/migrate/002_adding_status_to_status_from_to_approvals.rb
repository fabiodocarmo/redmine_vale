class AddingStatusToStatusFromToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :status_from_id, :integer
    add_column :approvals, :status_to_id  , :integer
  end
end
