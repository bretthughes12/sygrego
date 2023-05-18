class AddTicketFieldsToParticipant < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :registration_nbr, :string, limit: 24
    add_column :participants, :booking_nbr, :string, limit: 10
    add_column :participants, :exported, :boolean, default: false
    add_column :participants, :dirty, :boolean, default: false
  end
end
