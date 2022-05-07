class CreateBallotResults < ActiveRecord::Migration[7.0]
  def change
    create_table :ballot_results do |t|
      t.string :sport_name, limit: 20, null: false
      t.string :grade_name, limit: 50, null: false
      t.string :section_name, limit: 50
      t.string :preferred_section_name, limit: 50
      t.integer :entry_limit
      t.boolean :over_limit
      t.boolean :one_entry_per_group
      t.string :group_name, limit: 50, null: false
      t.boolean :new_group
      t.string :sport_entry_name
      t.string :sport_entry_status, limit: 20, null: false
      t.integer :factor

      t.timestamps
    end
  end
end
