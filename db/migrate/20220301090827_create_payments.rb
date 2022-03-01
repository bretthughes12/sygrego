class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :group, null: false, foreign_key: true
      t.decimal :amount, precision: 8, scale: 2, default: 0.0, null: false
      t.string :payment_type, limit: 20, null: false
      t.string :name, limit: 50
      t.string :reference, limit: 50
      t.boolean :reconciled, default: false
      t.datetime :paid_at
      t.bigint :updated_by

      t.timestamps
    end
  end
end
