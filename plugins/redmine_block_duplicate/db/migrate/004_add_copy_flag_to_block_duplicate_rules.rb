class AddCopyFlagToBlockDuplicateRules < ActiveRecord::Migration
  def change

    add_column :block_duplicates, :copy_flag, :boolean

  end
end
