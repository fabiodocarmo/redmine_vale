class DefaultValueToCustomField < ActiveRecord::Migration
  def change
    change_column_default :auto_change_statuses, :use_custom_field, false
    AutoChangeStatus.where(use_custom_field: nil).update_all({use_custom_field: false})
  end
end
