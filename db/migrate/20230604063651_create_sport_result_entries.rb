class CreateSportResultEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :sport_result_entries do |t|
      t.integer :court
      t.integer :match
      t.boolean :complete, default: false
      t.references :entry_a, foreign_key: { to_table: :sport_entries }
      t.integer :team_a
      t.integer :score_a, default: 0
      t.references :entry_b, foreign_key: { to_table: :sport_entries }
      t.integer :team_b
      t.integer :score_b, default: 0
      t.boolean :forfeit_a, default: false
      t.boolean :forfeit_b, default: false
      t.references :entry_umpire, foreign_key: { to_table: :groups }
      t.boolean :forfeit_umpire, default: false
      t.boolean :blowout_rule
      t.integer :forfeit_score
      t.integer :groups
      t.string :finals_format
      t.integer :start_court

      t.references :section, index: true

      t.timestamps
    end
  end
end
