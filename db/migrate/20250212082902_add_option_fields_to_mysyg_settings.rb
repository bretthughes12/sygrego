class AddOptionFieldsToMysygSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :mysyg_settings, :address_option, :string, limit: 10, default: "Show"
    add_column :mysyg_settings, :medical_option, :string, limit: 10, default: "Show"
    add_column :mysyg_settings, :allergy_option, :string, limit: 10, default: "Show"
    add_column :mysyg_settings, :dietary_option, :string, limit: 10, default: "Show"
  end
end
