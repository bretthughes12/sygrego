class AddStatusToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :status, :string, limit: 12, default: "Not Verified"
  end
end
