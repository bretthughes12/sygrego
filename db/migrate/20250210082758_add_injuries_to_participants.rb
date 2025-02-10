class AddInjuriesToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :medical_injuries, :text
  end
end
