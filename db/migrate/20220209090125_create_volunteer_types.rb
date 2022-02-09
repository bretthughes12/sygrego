class CreateVolunteerTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :volunteer_types do |t|
      t.string :name, limit: 100, null: false
      t.boolean :sport_related, default: false
      t.boolean :t_shirt, default: false
      t.text :description
      t.string :database_code, limit: 4
      t.boolean :active, default: true
      t.bigint :updated_by

      t.timestamps
    end

    add_index :volunteer_types, :name, unique: true
  end
end
