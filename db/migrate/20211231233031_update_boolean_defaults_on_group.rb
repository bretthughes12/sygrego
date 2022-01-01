class UpdateBooleanDefaultsOnGroup < ActiveRecord::Migration[7.0]
  def change
    change_column :groups, :admin_use, :boolean, default: false
    change_column :groups, :last_year, :boolean, default: false
  end
end
