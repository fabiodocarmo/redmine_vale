class AddChangeStatusAfterDueTime < ActiveRecord::Migration
  def change
    add_column :vsg_sla_slas, :change_status_after_due_time, :boolean, default: false
    add_column :vsg_sla_slas, :due_status_id               , :integer, default: false
  end
end
