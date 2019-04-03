class CreateAtribuicaoAutomaticas < ActiveRecord::Migration
  def change
    create_table :atribuicao_automaticas do |t|
      t.references :project
      t.references :tracker
      t.references :group
      t.boolean :redistribute
    end
  end
end
