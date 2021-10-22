class CreateVenues < ActiveRecord::Migration[6.1]
  def change
    create_table :venues do |t|
      t.string :name,  :limit => 50, :default => "", :null => false
      t.string :database_code, :limit => 4
      t.string   "address"
      t.bigint :updated_by
      t.boolean :active

      t.timestamps
    end

    add_index :venues, :name,                unique: true
    add_index :venues, :database_code,       unique: true
  end
end
