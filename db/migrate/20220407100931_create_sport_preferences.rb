class CreateSportPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :sport_preferences do |t|
      t.references :grade, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true
      t.integer :preference

      t.timestamps
    end
  end
end
