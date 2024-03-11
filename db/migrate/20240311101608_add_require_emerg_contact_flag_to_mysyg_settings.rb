class AddRequireEmergContactFlagToMysygSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :mysyg_settings, :require_emerg_contact, :boolean, default: false
  end
end
