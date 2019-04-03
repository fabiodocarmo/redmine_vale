class CreateDependentFields < ActiveRecord::Migration
  def change
    create_table :dependent_fields do |t|
      t.boolean :avaliable, :default => true

      t.references :project
      t.references :tracker
      t.references :main_field
      t.references :secondary_field
      t.string :main_field_value
      t.string :secondary_field_value
      t.boolean :not_nullable
    end

    add_index :dependent_fields, :project_id
    add_index :dependent_fields, :tracker_id
    add_index :dependent_fields, :main_field_id
    add_index :dependent_fields, :secondary_field_id
  end
end
