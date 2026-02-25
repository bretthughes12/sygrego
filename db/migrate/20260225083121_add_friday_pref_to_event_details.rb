class AddFridayPrefToEventDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :event_details, :service_pref_fri, :string, limit: 20, default: 'No preference'
  end
end
