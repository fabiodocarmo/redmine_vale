class AddColumnsLevelAndQuestionToSatisfactionSurvey < ActiveRecord::Migration
  def change

    add_column :satisfaction_surveys, :satisfaction_level, :integer
    add_column :satisfaction_surveys, :question, :text

  end
end
