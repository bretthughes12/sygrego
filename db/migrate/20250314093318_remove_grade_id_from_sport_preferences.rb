class RemoveGradeIdFromSportPreferences < ActiveRecord::Migration[8.0]
  def change
    remove_column :sport_preferences, :grade_id, :bigint
  end
end
