class AddMedicareOptionToMysygSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :mysyg_settings, :medicare_option, :string, limit: 10, default: "Show"
  end
end
