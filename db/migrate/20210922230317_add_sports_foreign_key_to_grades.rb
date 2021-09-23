class AddSportsForeignKeyToGrades < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :grades, :sports
  end
end
