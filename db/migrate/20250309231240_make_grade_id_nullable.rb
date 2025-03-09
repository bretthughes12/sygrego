class MakeGradeIdNullable < ActiveRecord::Migration[8.0]
  def up
    change_column :sport_preferences, :grade_id, :bigint, null: true
  end

  def down
    change_column :sport_preferences, :grade_id, :bigint, null: false
  end
end
