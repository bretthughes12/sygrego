class CreateVenues < ActiveRecord::Migration[6.1]
  def change
    create_table :venues do |t|
      t.string :name,  :limit => 50, :default => "", :null => false
      t.string :database_code, :limit => 4
      t.string   "address"
      t.float    "lat"
      t.float    "lng"
      t.bigint :updated_by

      t.timestamps
    end
  end
end
