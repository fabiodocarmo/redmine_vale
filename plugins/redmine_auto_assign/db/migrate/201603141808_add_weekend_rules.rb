class AddWeekendRules < ActiveRecord::Migration
  def change
    add_column :atribuicao_automaticas, :weekend_group_id, :integer
  end
end
