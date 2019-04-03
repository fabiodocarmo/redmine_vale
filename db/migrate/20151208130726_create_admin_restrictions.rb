class CreateAdminRestrictions < ActiveRecord::Migration
  def change
    create_table :admin_restrictions do |t|
      t.text :restrictions
      t.string :name

      t.timestamps null: false
    end
    add_column :users, :admin_restriction_id, :integer
    add_index :users, :admin_restriction_id
  end
end
