class Add2023FieldsToParticipants < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :emergency_email, :string, limit: 100
    add_column :participants, :camping_preferences, :string, limit: 100
  end
end
