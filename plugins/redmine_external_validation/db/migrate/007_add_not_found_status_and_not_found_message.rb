class AddNotFoundStatusAndNotFoundMessage < ActiveRecord::Migration
  def change
    add_column :external_validations, :not_found_status_id, :integer
    add_column :external_validations, :not_found_message  , :text
    add_column :external_validations, :private_journal  , :boolean
  end
end
