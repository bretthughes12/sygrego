class AddTicketEmailToGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :ticket_email, :string, limit: 100
  end
end
