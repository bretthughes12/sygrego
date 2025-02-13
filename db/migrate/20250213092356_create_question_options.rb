class CreateQuestionOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :question_options do |t|
      t.references :question, null: false, foreign_key: true
      t.integer :order_number, default: 1
      t.string :name

      t.timestamps
    end
  end
end
