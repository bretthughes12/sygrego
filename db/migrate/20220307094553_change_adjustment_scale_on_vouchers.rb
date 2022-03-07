class ChangeAdjustmentScaleOnVouchers < ActiveRecord::Migration[7.0]
  def change
    change_column :vouchers, :adjustment, :decimal, precision: 8, scale: 2, null: false, default: 1.0
  end
end
