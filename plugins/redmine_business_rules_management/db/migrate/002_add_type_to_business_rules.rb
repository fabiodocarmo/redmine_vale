class AddTypeToBusinessRules < ActiveRecord::Migration
  def change
    add_column :business_rules, :type, :string
  end
end
