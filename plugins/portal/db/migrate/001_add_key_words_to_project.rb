class AddKeyWordsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :key_words, :text
  end
end
