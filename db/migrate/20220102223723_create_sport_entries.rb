class CreateSportEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :sport_entries do |t|
      t.references :group, null: false, foreign_key: true
      t.references :grade, null: false, foreign_key: true
      t.bigint :section_id
      t.string :status, limit: 20, default: "Requested"
      t.integer :team_number, default: 1, null: false
      t.boolean :multiple_teams, default: false
      t.bigint :captaincy_id
      t.integer :chance_of_entry, default: 100
      t.bigint :updated_by

      t.timestamps
    end
  end
end
