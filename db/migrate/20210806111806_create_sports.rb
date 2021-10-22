class CreateSports < ActiveRecord::Migration[6.1]
  def change
    create_table :sports do |t|
      t.string :name, limit: 20, null: false
      t.string :classification, limit: 10, null: false
      t.boolean :active, default: true
      t.integer :max_indiv_entries_group, default: 0, null: false
      t.integer :max_team_entries_group, default: 0, null: false
      t.integer :max_entries_indiv, default: 0, null: false
      t.string  :draw_type, limit: 20, null: false
      t.boolean :bonus_for_officials, default: false
      t.string  :court_name, limit: 20, default: "Court"
      t.bigint  :updated_by

      t.timestamps
    end
  end
end
