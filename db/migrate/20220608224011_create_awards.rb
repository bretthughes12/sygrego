class CreateAwards < ActiveRecord::Migration[7.0]
  def change
    create_table :awards do |t|
      t.string :category, limit: 20, null: false
      t.string :submitted_by, limit: 100, null: false
      t.string :submitted_group, limit: 100, null: false
      t.string :name, limit: 100, null: false
      t.text :description, null: false
      t.boolean :flagged, default: false

      t.timestamps
    end

    add_index :awards, :name
  end
end
