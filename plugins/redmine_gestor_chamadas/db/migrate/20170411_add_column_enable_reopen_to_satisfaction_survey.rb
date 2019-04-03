class AddColumnEnableReopenToSatisfactionSurvey < ActiveRecord::Migration
  def change

    add_column :satisfaction_surveys, :enable_reopen, :boolean

  end
end
