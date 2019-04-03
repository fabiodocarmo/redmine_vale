class AddStatusToBlockDuplicateRules < ActiveRecord::Migration
  def change

    add_column :block_duplicates, :statuses, :text

  end
end
