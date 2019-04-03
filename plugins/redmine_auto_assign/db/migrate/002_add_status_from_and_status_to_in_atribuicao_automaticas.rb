class AddStatusFromAndStatusToInAtribuicaoAutomaticas < ActiveRecord::Migration
  def change
    add_column :atribuicao_automaticas, :status_from_id, :integer, index: true
    add_column :atribuicao_automaticas, :status_to_id, :integer, index: true

    AtribuicaoAutomatica.reset_column_information

    default_status = IssueStatus.order("position").pluck(:id).first
    AtribuicaoAutomatica.all.each do |atribuicao_automatica|
      atribuicao_automatica.status_to = default_status
      atribuicao_automatica.save!
    end
  end
end
