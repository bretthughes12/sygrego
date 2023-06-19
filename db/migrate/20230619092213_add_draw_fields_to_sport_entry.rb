class AddDrawFieldsToSportEntry < ActiveRecord::Migration[7.0]
  def change
    add_column :sport_entries, :group_number, :integer, default: 1
  end
end
