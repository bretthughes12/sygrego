class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :group, null: false, foreign_key: true
      t.string :name, limit: 50, null: false
      t.string :section, limit: 20, null: false
      t.string :question_type, limit: 20, null: false
      t.text :description
      t.integer :order_number, default: 1
      t.boolean :required, default: false

      t.timestamps
    end

    add_index :questions, ["group_id", "section", "order_number"]
  end
end
