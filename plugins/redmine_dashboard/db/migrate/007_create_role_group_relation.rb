class CreateRoleGroupRelation < ActiveRecord::Migration
  def self.up
    create_table :roles_groups, :id => false do |t|
      t.integer :group_id, :default => 0, :null => false
      t.integer :role_id, :default => 0, :null => false
    end
  end

  def self.down 
    drop_table :roles_groups
  end
end