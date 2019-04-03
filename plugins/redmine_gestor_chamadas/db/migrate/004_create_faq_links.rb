class CreateFaqLinks < ActiveRecord::Migration
  def change
    create_table :faq_links do |t|
      t.references :tracker
      t.text :faq_link
    end
    add_index :faq_links, :tracker_id
  end
end
