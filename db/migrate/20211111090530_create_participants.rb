class CreateParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :participants do |t|
      t.bigint :group_id, default: 0, null: false
      t.string :first_name, limit: 20, null: false
      t.string :surname, limit: 20, null: false
      t.boolean :coming, default: true
      t.integer :age, default: 30, null: false
      t.string :gender, limit: 1, default: "M", null: false
      t.integer :days, default: 3, null: false
      t.string :address, limit: 200
      t.string :suburb, limit: 40
      t.integer :postcode
      t.string :phone_number, limit: 20
      t.string :encrypted_medicare_number
      t.string :encrypted_medicare_number_iv
      t.string :medical_info, limit: 255
      t.string :medications, limit: 255
      t.integer :years_attended
      t.integer :database_rowid
      t.integer :lock_version, default: 0
      t.boolean :spectator, default: false
      t.boolean :onsite, default: true
      t.boolean :helper, default: false
      t.boolean :group_coord, default: false
      t.boolean :sport_coord, default: false
      t.boolean :guest, default: false
      t.boolean :withdrawn, default: false
      t.decimal :fee_when_withdrawn, precision: 8, scale: 2, default: "0.0"
      t.boolean :late_fee_charged, default: false
      t.boolean :driver, default: false
      t.string :number_plate, limit: 10
      t.boolean :early_bird, default: false
      t.string :email, limit: 100
      t.string :mobile_phone_number, limit: 20
      t.string :dietary_requirements, limit: 255
      t.string :emergency_contact, limit: 40
      t.string :emergency_relationship, limit: 20
      t.string :emergency_phone_number, limit: 20
      t.decimal :amount_paid, precision: 8, scale: 2, default: "0.0"
      t.string :status, limit: 20, default: "Accepted"
      t.string :encrypted_wwcc_number
      t.string :encrypted_wwcc_number_iv
      t.boolean :driver_signature, default: false
      t.datetime :driver_signature_date
      t.bigint :updated_by

      t.timestamps
    end

    add_index :participants, ["group_id", "surname", "first_name"], unique: true
    add_index :participants, ["surname", "first_name"]
    add_index :participants, :coming
    add_foreign_key :participants, :groups
  end
end
