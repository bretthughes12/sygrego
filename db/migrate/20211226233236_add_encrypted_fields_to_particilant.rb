class AddEncryptedFieldsToParticilant < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :wwcc_number, :string
    add_column :participants, :medicare_number, :string
  end
end
