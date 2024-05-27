class AddTransferFieldsToParticipants < ActiveRecord::Migration[7.1]
  def change
    add_column :participants, :transfer_email, :string, limit: 100
    add_column :participants, :transfer_token, :string
    add_index :participants, :transfer_token
  end
end
