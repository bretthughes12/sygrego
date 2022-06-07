class CreateWardenZones < ActiveRecord::Migration[7.0]
  def change
    create_table :warden_zones do |t|
      t.integer :zone
      t.text :warden_info

      t.timestamps
    end
  end
end
