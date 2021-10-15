class CreateEventDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :event_details do |t|
      t.boolean :onsite
      t.boolean :fire_pit
      t.text :camping_rqmts
      t.integer :tents
      t.integer :caravans
      t.integer :marquees
      t.string :marquee_sizes, limit: 255
      t.string :marquee_co, limit: 50
      t.string :buddy_interest, limit: 50
      t.text :buddy_comments
      t.string :service_pref_sat, limit: 20, default: "No preference"
      t.string :service_pref_sun, limit: 20, default: "No preference"
      t.integer :estimated_numbers
      t.integer :number_of_vehicles
      t.bigint :updated_by

      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
