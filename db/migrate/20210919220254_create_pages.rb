class CreatePages < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.string :name, limit: 50
      t.string :permalink, limit: 20
      t.boolean :admin_use

      t.timestamps
    end
  end
end
