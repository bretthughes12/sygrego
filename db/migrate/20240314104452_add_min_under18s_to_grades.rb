class AddMinUnder18sToGrades < ActiveRecord::Migration[7.1]
  def change
    add_column :grades, :min_under_18s, :integer, default: 0, null: false
  end
end
