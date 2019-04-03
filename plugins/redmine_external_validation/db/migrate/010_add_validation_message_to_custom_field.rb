class AddValidationMessageToCustomField < ActiveRecord::Migration
  def change
    remove_column :external_validation_roles, :private_journal, :boolean
    add_column    :external_validation_roles, :message_custom_field_id, :integer

    remove_column :external_validations, :private_journal, :boolean
    add_column    :external_validations, :message_custom_field_id, :integer
  end
end
