class AddSecondCustomFieldToAtribuicaoAutomatica < ActiveRecord::Migration
  def change
    add_column :atribuicao_automaticas, :second_custom_field_id, :integer, index: true
    add_column :atribuicao_automaticas, :second_custom_field_value, :string
  end
end
