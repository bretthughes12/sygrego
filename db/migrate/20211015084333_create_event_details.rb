class CreateEventDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :event_details do |t|
      t.boolean :onsite, default: true
      t.boolean :fire_pit, default: true
      t.text :camping_rqmts
      t.integer :tents, default: 0
      t.integer :caravans, default: 0
      t.integer :marquees, default: 0
      t.string :marquee_sizes, limit: 255
      t.string :marquee_co, limit: 50
      t.string :buddy_interest, limit: 50
      t.text :buddy_comments
      t.string :service_pref_sat, limit: 20, default: "No preference"
      t.string :service_pref_sun, limit: 20, default: "No preference"
      t.integer :estimated_numbers, default: 0
      t.integer :number_of_vehicles, default: 0
      t.bigint :updated_by

      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
