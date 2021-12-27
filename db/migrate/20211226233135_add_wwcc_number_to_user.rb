class AddWwccNumberToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :wwcc_number, :string
  end
end
