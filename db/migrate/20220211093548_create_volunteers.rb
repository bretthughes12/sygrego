class CreateVolunteers < ActiveRecord::Migration[7.0]
  def change
    create_table :volunteers do |t|
      t.string :description, limit: 100, null: false
      t.string :email, limit: 40
      t.string :mobile_number, limit: 20
      t.string :t_shirt_size, limit: 10
      t.boolean :mobile_confirmed, default: false
      t.boolean :details_confirmed, default: false
      t.string :equipment_out
      t.string :equipment_in
      t.boolean :collected, default: false
      t.boolean :returned, default: false
      t.text :notes
      t.bigint :session_id
      t.bigint :section_id
      t.bigint :participant_id
      t.integer :lock_version, default: 0
      t.bigint :updated_by

      t.references :volunteer_type, foreign_key: true

      t.timestamps
    end
    add_index :volunteers, :participant_id
  end
end
