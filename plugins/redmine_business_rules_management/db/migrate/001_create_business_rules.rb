class CreateBusinessRules < ActiveRecord::Migration
  def change
    create_table :business_rules do |t|
      t.text :rule, null: false
      t.text :parameters
    end
  end
end
