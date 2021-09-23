class CreateGrades < ActiveRecord::Migration[6.1]
  def change
    create_table :grades do |t|
      t.integer :database_rowid
      t.integer :sport_id, default: 0, null: false
      t.string :name, limit: 50, null: false
      t.boolean :active
      t.string :grade_type, limit: 10, default: "Team", null: false
      t.string :gender_type, limit: 10, default: "Open", null: false
      t.integer :max_age, default: 29, null: false
      t.integer :min_age, default: 11, null: false
      t.integer :max_participants, default: 0, null: false
      t.integer :min_participants, default: 0, null: false
      t.integer :min_males, default: 0, null: false
      t.integer :min_females, default: 0, null: false
      t.string :status, limit: 20, default: "Open", null: false
      t.integer :entry_limit
      t.integer :starting_entry_limit
      t.integer :team_size, default: 1
      t.datetime :waitlist_expires_at
      t.integer :entries_to_be_allocated, default: 999
      t.boolean :over_limit
      t.boolean :one_entry_per_group

      t.timestamps
    end
  end
end
