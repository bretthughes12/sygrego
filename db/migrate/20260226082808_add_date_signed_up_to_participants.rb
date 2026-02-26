class AddDateSignedUpToParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :participants, :date_signed_up, :date
  end
end
