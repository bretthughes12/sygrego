class AddMaxEntriesToGrades < ActiveRecord::Migration[8.0]
  def change
    add_column :grades, :max_indiv_entries_group, :integer
    add_column :grades, :max_team_entries_group, :integer
  end
end
