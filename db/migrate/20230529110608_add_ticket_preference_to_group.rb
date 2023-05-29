class AddTicketPreferenceToGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :ticket_preference, :string, limit: 20, default: 'Send to GC'
  end
end
