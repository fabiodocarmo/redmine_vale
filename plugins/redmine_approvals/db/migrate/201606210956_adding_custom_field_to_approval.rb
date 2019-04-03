class AddingCustomFieldToApproval < ActiveRecord::Migration
  def change
    add_column :approvals, :use_second_custom_field  , :boolean, index: true, default: false
    add_column :approvals, :second_custom_field_id   , :integer, index: true, default: false
    add_column :approvals, :second_custom_field_value, :text   , index: true, default: false
  end
end
