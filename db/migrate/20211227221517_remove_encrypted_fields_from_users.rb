class RemoveEncryptedFieldsFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :encrypted_wwcc_number, :string
    remove_column :users, :encrypted_wwcc_number_iv, :string
  end
end
