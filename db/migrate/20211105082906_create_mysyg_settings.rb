class CreateMysygSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :mysyg_settings do |t|
      t.string :mysyg_name, limit: 50
      t.boolean :mysyg_enabled, default: false
      t.boolean :mysyg_open, default: false
      t.text :participant_instructions
      t.decimal :extra_fee_total, precision: 8, scale: 2, default: "0.0"
      t.decimal :extra_fee_per_day, precision: 8, scale: 2, default: "0.0"
      t.boolean :show_sports_in_mysyg, default: true
      t.boolean :show_volunteers_in_mysyg, default: true
      t.boolean :show_finance_in_mysyg, default: true
      t.boolean :show_group_extras_in_mysyg, default: true
      t.string :approve_option, default: "Normal"
      t.string :team_sport_view_strategy, default: "Show all"
      t.string :indiv_sport_view_strategy, default: "Show all"
      t.string :mysyg_code, limit: 25

      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
