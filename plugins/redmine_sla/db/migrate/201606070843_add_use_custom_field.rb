class AddUseCustomField < ActiveRecord::Migration
  def change
    add_column :vsg_sla_slas, :use_custom_field, :boolean, default: false
    add_column :vsg_sla_slas, :main_custom_field_id, :integer
    add_column :vsg_sla_slas, :main_custom_field_value, :string
  end
end
