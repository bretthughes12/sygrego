class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :abbr, limit: 4, null: false
      t.string :name, limit: 100, null: false
      t.string :short_name, limit: 50, null: false
      t.boolean :coming, default: true
      t.integer :lock_version, default: 0
      t.integer :database_rowid
      t.boolean :new_group, default: true
      t.string :trading_name, limit: 100, null: false
      t.string :address, limit: 200, null: false
      t.string :suburb, limit: 40, null: false
      t.integer :postcode, null: false
      t.string :phone_number, limit: 20
      t.boolean :last_year
      t.boolean :admin
      t.decimal :late_fees, precision: 8, scale: 2, default: 0.0
      t.integer :allocation_bonus, default: 0
      t.string :email, limit: 100
      t.string :website, limit: 100
      t.string :denomination, limit: 40, null: false
      t.integer :years_attended, default: 0
      t.string :status, limit: 12, default: "Stale"
      t.string :age_demographic, limit: 40
      t.string :group_focus, limit: 100
      t.bigint :updated_by

      t.timestamps
    end
  end
end
