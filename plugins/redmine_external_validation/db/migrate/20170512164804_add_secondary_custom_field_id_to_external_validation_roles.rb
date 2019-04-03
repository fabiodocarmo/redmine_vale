class AddSecondaryCustomFieldIdToExternalValidationRoles < ActiveRecord::Migration
  def change
    add_column :external_validation_roles, :secondary_custom_field_id, :integer
  end
end
