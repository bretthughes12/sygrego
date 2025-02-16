class CreateQuestionResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :question_responses do |t|
      t.references :participant, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :answer

      t.timestamps
    end
  end
end
