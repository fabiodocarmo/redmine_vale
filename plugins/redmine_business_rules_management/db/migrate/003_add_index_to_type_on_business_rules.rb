class AddIndexToTypeOnBusinessRules < ActiveRecord::Migration
  def change
    add_index :business_rules, :type
  end
end
