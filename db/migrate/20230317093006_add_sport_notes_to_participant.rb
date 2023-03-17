class AddSportNotesToParticipant < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :sport_notes, :string
  end
end
