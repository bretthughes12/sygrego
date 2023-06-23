class DropSportResultEntries < ActiveRecord::Migration[7.0]
  def change
    drop_table :sport_result_entries
  end
end
