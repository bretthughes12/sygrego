class CreateRoundRobinMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :round_robin_matches do |t|
      t.integer :court, default: 1
      t.integer :match
      t.boolean :complete, default: false
      t.bigint :entry_a_id
      t.integer :score_a, default: 0
      t.bigint :entry_b_id
      t.integer :score_b, default: 0
      t.boolean :forfeit_a, default: false
      t.boolean :forfeit_b, default: false
      t.bigint :entry_umpire_id
      t.boolean :forfeit_umpire, default: false
      t.bigint :draw_number

      t.references :section, index: true

      t.bigint :updated_by
      t.timestamps

      t.index ["draw_number"], name: "index_round_robin_matches_on_draw_number"
      t.index ["entry_a_id"], name: "index_round_robin_matches_on_entry_a_id"
      t.index ["entry_b_id"], name: "index_round_robin_matches_on_entry_b_id"
      t.index ["entry_umpire_id"], name: "index_round_robin_matches_on_entry_umpire_id"
    end
  end
end
