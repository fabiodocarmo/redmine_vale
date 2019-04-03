class CreateSatisfactionQuestions < ActiveRecord::Migration
  def change
    create_table :satisfaction_questions do |t|
      t.text :question
      t.text :question_en
      t.text :question_es
      t.boolean :reopen_enabled
    end
  end
end
