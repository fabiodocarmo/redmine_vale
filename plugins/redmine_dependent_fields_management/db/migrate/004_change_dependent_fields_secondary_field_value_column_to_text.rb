class ChangeDependentFieldsSecondaryFieldValueColumnToText < ActiveRecord::Migration
  def change
    change_column(:dependent_fields, :secondary_field_value, :text)
  end
end
