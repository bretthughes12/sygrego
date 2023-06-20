class AddDrawFieldsToSection < ActiveRecord::Migration[7.0]
  def change
    add_column :sections, :finals_format, :string, limit: 20
    add_column :sections, :number_of_groups, :integer, default: 1
    add_column :sections, :start_court, :integer, default: 1
  end
end
