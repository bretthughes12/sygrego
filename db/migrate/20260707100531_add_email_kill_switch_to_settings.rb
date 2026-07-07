class AddEmailKillSwitchToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :send_emails, :boolean, default: true, null: false
  end
end
