class CreateRoundRedistributes < ActiveRecord::Migration
  def change
    create_table :round_redistributes do |t|
      t.references :group
      t.integer :times, default: -1
    end
    
    add_index :round_redistributes, :group_id
  end
end
