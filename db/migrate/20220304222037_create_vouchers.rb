class CreateVouchers < ActiveRecord::Migration[7.0]
  def change
    create_table :vouchers do |t|
      t.references :group, null: true
      t.string :name, limit: 20, null: false
      t.integer :limit, default: 1
      t.datetime :expiry
      t.string :type, limit: 15, default: "Multiply", null: false
      t.decimal :adjustment, precision: 8, scope: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
