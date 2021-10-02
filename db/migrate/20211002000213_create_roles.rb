class CreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :roles do |t|
      t.string :name, limit: 20
      t.integer :group_id

      t.timestamps
    end
  end
end
