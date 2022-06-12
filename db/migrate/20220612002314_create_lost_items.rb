class CreateLostItems < ActiveRecord::Migration[7.0]
  def change
    create_table :lost_items do |t|
      t.string :category, limit: 30, null: false
      t.string :description, limit: 255, null: false
      t.boolean :claimed, default: false
      t.string :name, limit: 40
      t.string :address, limit: 200
      t.string :suburb, limit: 40
      t.integer :postcode
      t.string :phone_number, limit: 30
      t.string :email, limit: 100
      t.integer :lock_version, default: 0

      t.timestamps
    end
  end
end
