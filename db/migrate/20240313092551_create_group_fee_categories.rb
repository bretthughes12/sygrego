class CreateGroupFeeCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :group_fee_categories do |t|
      t.references :group, null: false, foreign_key: true
      t.string :description, limit: 40
      t.string :adjustment_type, limit: 15, default: "Add"
      t.decimal :amount, precision: 8, scale: 2, default: 1.0

      t.timestamps
    end
  end
end
