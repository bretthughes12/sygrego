class CreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :roles do |t|
      t.string :name, limit: 20
      t.boolean :group_related, default: false
      t.boolean :participant_related, default: false

      t.timestamps
    end

    add_index :roles, :name, unique: true
  end
end
