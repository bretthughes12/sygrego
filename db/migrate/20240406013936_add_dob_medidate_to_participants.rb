class AddDobMedidateToParticipants < ActiveRecord::Migration[7.1]
  def change
    add_column :participants, :date_of_birth, :date
    add_column :participants, :medicare_expiry, :date
  end
end
