class AddOtherNotifications < ActiveRecord::Migration
  def change
    rename_column :vsg_sla_slas, :notify_before_hour  , :notify_overdue_hour
    rename_column :vsg_sla_slas, :notify_assign_to    , :notify_overdue_assign_to
    rename_column :vsg_sla_slas, :notify_author       , :notify_overdue_author
    add_column :vsg_sla_slas   , :notify_overdue_group, :boolean
    add_column :vsg_sla_slas   , :overdue_group_id    , :integer
    add_index  :vsg_sla_slas   , :overdue_group_id

    add_column :vsg_sla_slas, :notify_inactivity_hour, :integer, default: 0
    add_column :vsg_sla_slas, :notify_inactivity_assign_to     , :boolean
    add_column :vsg_sla_slas, :notify_inactivity_author        , :boolean
    add_column :vsg_sla_slas, :notify_inactivity_group         , :boolean
    add_column :vsg_sla_slas, :inactivity_group_id             , :integer
    add_index  :vsg_sla_slas, :inactivity_group_id

    add_column :vsg_sla_slas, :notify_open_time_hour          , :integer, default: 0
    add_column :vsg_sla_slas, :notify_open_time_assign_to     , :boolean
    add_column :vsg_sla_slas, :notify_open_time_author        , :boolean
    add_column :vsg_sla_slas, :notify_open_time_group         , :boolean
    add_column :vsg_sla_slas, :open_time_group_id             , :integer
    add_index  :vsg_sla_slas, :open_time_group_id
  end
end
