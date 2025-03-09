class AddSportsAndLevelToSportPreferences < ActiveRecord::Migration[8.0]
  def change
    add_reference :sport_preferences, :sport
    add_column :sport_preferences, :level, :string, limit: 100
    remove_foreign_key :sport_preferences, :grades
  end
end
