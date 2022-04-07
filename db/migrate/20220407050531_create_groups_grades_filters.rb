class CreateGroupsGradesFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :groups_grades_filters do |t|
      t.references :grade, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
