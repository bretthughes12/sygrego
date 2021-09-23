class AddUpdatedByToGrades < ActiveRecord::Migration[6.1]
  def change
    add_column :grades, :updated_by, :bigint
  end
end
