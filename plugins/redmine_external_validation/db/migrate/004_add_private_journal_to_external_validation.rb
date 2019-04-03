class AddPrivateJournalToExternalValidation < ActiveRecord::Migration
  def change
    add_column :external_validation_roles, :private_journal, :boolean, default: false
  end
end
