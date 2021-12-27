class RemoveEncryptedFieldsFromParticipants < ActiveRecord::Migration[7.0]
  def change
    remove_column :participants, :encrypted_wwcc_number, :string
    remove_column :participants, :encrypted_wwcc_number_iv, :string
    remove_column :participants, :encrypted_medicare_number, :string
    remove_column :participants, :encrypted_medicare_number_iv, :string
  end
end
