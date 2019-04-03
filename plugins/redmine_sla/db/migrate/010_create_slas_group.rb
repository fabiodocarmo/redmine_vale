class CreateSlasGroup < ActiveRecord::Migration
  def change
    create_table :users_vsg_sla_slas do |t|
      t.integer :sla_id, index: true, foreign_key: true
      t.integer :group_id, index: true, foreign_key: true
    end
  end
end
