class DropGroupsGradesFilters < ActiveRecord::Migration[8.0]
  def up
    drop_table :groups_grades_filters
  end

  def down
    create_table :groups_grades_filters do |t|
      t.references :grade, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
