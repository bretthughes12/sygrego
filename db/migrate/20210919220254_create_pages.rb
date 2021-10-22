class CreatePages < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.string :name, limit: 50
      t.string :permalink, limit: 20
      t.boolean :admin_use

      t.timestamps
    end

    add_index :pages, :name,                unique: true
    add_index :pages, :permalink,           unique: true
  end
end
