class AddNotifyFields < ActiveRecord::Migration
  def change
    add_column :vsg_sla_slas, :notify_before_hour, :integer, default: 0
    add_column :vsg_sla_slas, :notify_assign_to, :boolean
    add_column :vsg_sla_slas, :notify_author, :boolean
  end
end
