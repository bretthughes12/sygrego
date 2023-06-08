class ChangeUmpireForeignKeyyToSportEntryOnSportResultEntries < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :sport_result_entries, column: :entry_umpire_id
    remove_foreign_key :sport_result_entries, column: :entry_a_id
    remove_foreign_key :sport_result_entries, column: :entry_b_id
  end
end
