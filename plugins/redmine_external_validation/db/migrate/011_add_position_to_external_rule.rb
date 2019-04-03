class AddPositionToExternalRule < ActiveRecord::Migration
  def change
    add_column :external_validation_roles, :position, :integer
  end
end
