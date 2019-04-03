class ChangeBlockDuplicatesProjectColumnToText < ActiveRecord::Migration
  def change
    change_column(:block_duplicates, :project_id, :text)
  end
end
