class AddInvoiceTypeToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :invoice_type, :string, limit: 20, default: 'Unspecified', null: false
  end
end
