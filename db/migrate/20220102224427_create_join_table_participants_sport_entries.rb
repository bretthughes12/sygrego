class CreateJoinTableParticipantsSportEntries < ActiveRecord::Migration[7.0]
  def change
    create_join_table :participants, :sport_entries do |t|
      # t.index [:participant_id, :sport_entry_id]
      # t.index [:sport_entry_id, :participant_id]
    end
  end
end
