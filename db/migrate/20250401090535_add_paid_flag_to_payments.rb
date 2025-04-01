class AddPaidFlagToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :paid, :boolean, default: false
  end
end
