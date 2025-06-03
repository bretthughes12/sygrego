class AddEmailSentToVolunteers < ActiveRecord::Migration[8.0]
  def change
    add_column :volunteers, :email_sent, :boolean, default: false
  end
end
