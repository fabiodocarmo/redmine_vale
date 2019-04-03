class CreateBlockDuplicates < ActiveRecord::Migration
  def change
    create_table :block_duplicates do |t|
      t.references :project
      t.references :tracker
      t.text :custom_fields
    end
    add_index :block_duplicates, :project_id
    add_index :block_duplicates, :tracker_id
  end
end
