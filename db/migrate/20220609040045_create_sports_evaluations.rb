class CreateSportsEvaluations < ActiveRecord::Migration[7.0]
  def change
    create_table :sports_evaluations do |t|
      t.string :sport, limit: 20, null: false
      t.string :section, limit: 50, null: false
      t.string :session, limit: 50, null: false
      t.string :venue_rating, limit: 10, null: false
      t.string :equipment_rating, null: false
      t.string :length_rating, null: false
      t.string :umpiring_rating, null: false
      t.string :results_rating, null: false
      t.string :time_rating, null: false
      t.string :support_rating, null: false
      t.string :safety_rating, null: false
      t.string :scoring_rating, null: false
      t.text :worked_well
      t.text :to_improve
      t.text :suggestions

      t.timestamps
    end

    add_index :sports_evaluations, :section
  end
end
