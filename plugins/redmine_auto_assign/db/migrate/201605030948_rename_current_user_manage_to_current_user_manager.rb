class RenameCurrentUserManageToCurrentUserManager < ActiveRecord::Migration
  def change
    AtribuicaoAutomatica.reset_column_information
    AtribuicaoAutomatica.where(redistribute: :current_user_manage).update_all(redistribute: :current_user_manager)
  end
end
