class AddPreferredSectionIdToSportEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :sport_entries, :preferred_section_id, :bigint
  end
end
