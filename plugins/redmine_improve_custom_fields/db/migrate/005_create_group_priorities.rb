class CreateGroupPriorities < ActiveRecord::Migration
  def change
    create_table :improvecf_group_priorities do |t|
      t.integer :author_id
      t.references :enumeration, index: true
      t.references :tracker    , index: true
    end

    add_index  :improvecf_group_priorities, [:author_id]
    add_index  :improvecf_group_priorities, [:author_id, :tracker_id]
  end
end
