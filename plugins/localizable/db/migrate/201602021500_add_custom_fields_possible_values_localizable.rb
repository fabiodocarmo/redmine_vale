class AddCustomFieldsPossibleValuesLocalizable < ActiveRecord::Migration

  def change
    add_column :custom_fields, :is_possible_values_localizable, :boolean, :default => true
  end

end
