class AddAutoSubjectToTrackers < ActiveRecord::Migration
  def change
    add_column :trackers, :auto_subject, :text
  end
end
