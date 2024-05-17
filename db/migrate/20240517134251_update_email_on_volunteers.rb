class UpdateEmailOnVolunteers < ActiveRecord::Migration[7.1]
  def change
    change_column :volunteers, :email, :string, limit: 100
  end
end
