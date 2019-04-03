class AddToleranceToExternalRule < ActiveRecord::Migration
  def change
    add_column :external_validation_roles, :tolerance, :float
  end
end
