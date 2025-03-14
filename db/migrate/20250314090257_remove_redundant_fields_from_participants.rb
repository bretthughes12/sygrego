class RemoveRedundantFieldsFromParticipants < ActiveRecord::Migration[8.0]
  def change
    remove_column :participants, :phone_number, :string
    remove_column :participants, :camping_preferences, :string
    remove_column :participants, :sport_notes, :string
    remove_column :participants, :driving_to_syg, :boolean
  end
end
