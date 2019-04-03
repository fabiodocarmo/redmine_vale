class AddUserCustomFieldToAtribuicaoAutomatica < ActiveRecord::Migration
  def change
    add_column :atribuicao_automaticas, :user_custom_field_id, :integer
  end
end
