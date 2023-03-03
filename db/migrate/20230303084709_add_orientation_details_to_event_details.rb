class AddOrientationDetailsToEventDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :event_details, :orientation_details, :string, limit: 100
  end
end
