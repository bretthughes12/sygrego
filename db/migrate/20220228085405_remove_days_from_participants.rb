class RemoveDaysFromParticipants < ActiveRecord::Migration[7.0]
  def change
    remove_column :participants, :days
  end
end
