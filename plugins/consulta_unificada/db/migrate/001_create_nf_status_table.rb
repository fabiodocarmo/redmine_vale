class CreateNfStatusTable < ActiveRecord::Migration
  def change
    create_table :nf_statuses do |t|
      t.string :status
      t.string :name
      t.string :source
      t.string :warning_msg
    end
  end
end
