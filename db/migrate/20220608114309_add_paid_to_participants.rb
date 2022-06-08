class AddPaidToParticipants < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :paid, :boolean, default: false
  end
end
