class AddGroupToSportResultEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :sport_result_entries, :group, :integer
    add_column :sport_result_entries, :updated_by, :bigint
  end
end
