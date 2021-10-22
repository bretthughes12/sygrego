class CreateSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :sessions do |t|
      t.string :name, null:false
      t.boolean :active, default: true
      t.integer :database_rowid
      t.bigint :updated_by

      t.timestamps
    end

    add_index :sessions, :name,                unique: true
    add_index :sessions, :database_rowid,      unique: true
  end
end
