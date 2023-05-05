class AddTimelines < ActiveRecord::Migration[7.0]
  def change
    create_table :timelines do |t|
      t.date :key_date, null: false
      t.string :name, limit: 50
      t.string :description, limit: 255

      t.timestamps
    end

    add_index :timelines, [:key_date, :name]
  end
end
