class CreateOrientationDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :orientation_details do |t|
      t.string :name, limit: 20
      t.string :venue_name
      t.string :venue_address
      t.datetime :event_date_time

      t.timestamps
    end
  end
end
