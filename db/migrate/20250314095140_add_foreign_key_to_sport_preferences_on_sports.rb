class AddForeignKeyToSportPreferencesOnSports < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :sport_preferences, :sports
  end
end
