class CreateSatisfactionsTable < ActiveRecord::Migration
  def change
    create_table :satisfaction_surveys do |t|
      t.references :issue
      t.text :satisfaction
      t.text :comment
      t.boolean :issue_reopened
    end
  	add_index :satisfaction_surveys, :issue_id
  end
end
