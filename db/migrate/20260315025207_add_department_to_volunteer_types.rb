class AddDepartmentToVolunteerTypes < ActiveRecord::Migration[8.1]
  def change
    add_column :volunteer_types, :department, :string, limit: 20, default: 'Administration', null: false
  end
end
