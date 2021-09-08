class CreateSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :sessions do |t|
      t.string :name, null:false
      t.boolean :active, default: true
      t.bigint :updated_by

      t.timestamps
    end
  end
end
