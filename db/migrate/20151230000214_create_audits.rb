class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.string :klazz_name
      t.string :col_name
      t.string :action
      t.text :value_was
      t.text :value
      t.integer :resource_id

      t.timestamps null: false
    end
  end
end
