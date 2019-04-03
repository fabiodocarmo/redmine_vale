class AddManualSelectData < ActiveRecord::Migration
  def change
    add_column :vsg_sla_slas, :manual_date_select, :boolean, default: false
  end
end
