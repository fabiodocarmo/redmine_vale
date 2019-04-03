class CreateExternalValidationQueries < ActiveRecord::Migration
  def change
    create_table :external_validation_queries do |t|
      t.integer :external_validation_id

      t.integer :custom_field_id
      t.string  :field_name
    end
  end
end
