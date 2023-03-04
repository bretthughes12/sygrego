class AddAllergiesToParticipants < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :allergies, :string, limit: 255
  end
end
