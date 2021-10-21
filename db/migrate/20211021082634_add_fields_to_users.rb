class AddFieldsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string, limit: 40, null: false, default: ""
    add_column :users, :group_role, :string, limit: 100
    add_column :users, :address, :string, limit: 200
    add_column :users, :suburb, :string, limit: 40
    add_column :users, :postcode, :integer, default: 0
    add_column :users, :phone_number, :string, limit: 30
    add_column :users, :gc_reference, :string, limit: 40
    add_column :users, :gc_reference_phone, :string, limit: 30
    add_column :users, :years_as_gc, :integer, default: 0
    add_column :users, :primary_gc, :boolean, default: false
    add_column :users, :encrypted_wwcc_number, :string
    add_column :users, :encrypted_wwcc_number_iv, :string
  end
end
