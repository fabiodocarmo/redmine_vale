class AddErrorsCustomFieldToExternalValidation < ActiveRecord::Migration
  def change
    add_column :external_validations, :errors_custom_field_id, :integer

    add_column :external_validation_roles, :error_id      , :string
    add_column :external_validation_roles, :error_message , :text

    add_column :external_validation_roles, :constant      , :boolean
    add_column :external_validation_roles, :constant_value, :text

    drop_table :external_validation_constant_roles
  end
end
