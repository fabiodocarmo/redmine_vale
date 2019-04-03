class AddCustomFieldToAtribuicaoAutomatica < ActiveRecord::Migration
  def change
    add_column :atribuicao_automaticas, :use_custom_field, :boolean, index: true, default: false
    add_column :atribuicao_automaticas, :custom_field_id, :integer, index: true
    add_column :atribuicao_automaticas, :custom_field_value, :string
  end
end
