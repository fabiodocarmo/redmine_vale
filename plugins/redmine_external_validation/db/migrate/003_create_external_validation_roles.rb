class CreateExternalValidationRoles < ActiveRecord::Migration
  def change
    create_table :external_validation_roles do |t|
      t.integer :external_validation_id

      t.integer :custom_field_id
      t.string  :field_name

      t.integer :error_status_id
    end
  end
end
