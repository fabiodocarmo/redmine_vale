class ChangeRedistributeToString < ActiveRecord::Migration
  def change
    change_column :atribuicao_automaticas, :redistribute, :string
  end
end
