class AddFormatToExternalValidation < ActiveRecord::Migration
  def change
    add_column :external_validation_roles, :format, :string, default: false
  end
end
