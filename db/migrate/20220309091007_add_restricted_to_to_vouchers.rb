class AddRestrictedToToVouchers < ActiveRecord::Migration[7.0]
  def change
    add_column :vouchers, :restricted_to, :string, limit: 20
  end
end
