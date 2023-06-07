class AddRestrictPassworddToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :protect_password, :boolean, default: false
  end
end
