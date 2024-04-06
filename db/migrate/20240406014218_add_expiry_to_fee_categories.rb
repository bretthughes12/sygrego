class AddExpiryToFeeCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :group_fee_categories, :expiry_date, :date
  end
end
