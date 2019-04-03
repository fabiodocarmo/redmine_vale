class AddColumnAll < ActiveRecord::Migration
  def change
    add_column :vsg_sla_slas, :all_projects, :boolean, default: false
    add_column :vsg_sla_slas, :all_trackers, :boolean, default: false
    add_column :vsg_sla_slas, :all_enumerations, :boolean, default: false
    add_column :vsg_sla_slas, :all_groups, :boolean, default: false
  end
end
