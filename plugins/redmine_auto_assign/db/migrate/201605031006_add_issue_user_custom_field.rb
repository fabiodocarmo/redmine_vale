class AddIssueUserCustomField < ActiveRecord::Migration
  def change
    add_column :atribuicao_automaticas, :issue_user_custom_field_id, :integer
  end
end
