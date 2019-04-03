class CreateExternalValidationConstantRoles < ActiveRecord::Migration
  def change
    create_table :external_validation_constant_roles do |t|
      t.integer :external_validation_id

      t.string :constant_value
      t.string :field_name
      t.string :format

      t.boolean :private_journal, default: false
      t.text :error_message

      t.integer :error_status_id
    end
  end
end
