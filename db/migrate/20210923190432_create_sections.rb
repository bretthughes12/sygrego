class CreateSections < ActiveRecord::Migration[6.1]
  def change
    create_table :sections do |t|
      t.bigint :grade_id, default: 0, null: false
      t.string :name, limit: 50, null: false
      t.boolean :active
      t.bigint :venue_id, default: 0, null: false
      t.bigint :session_id, default: 0, null: false
      t.integer :database_rowid
      t.integer :number_in_draw
      t.integer :year_introduced
      t.integer :number_of_courts, default: 1
      t.bigint :updated_by

      t.timestamps
    end

    add_index :sections, :name, unique: true
    add_foreign_key :sections, :grades
    add_foreign_key :sections, :venues
    add_foreign_key :sections, :sessions
  end
end
