class AddToggleFieldsToMysygSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :mysyg_settings, :show_sports_on_signup, :boolean, default: false
    add_column :mysyg_settings, :collect_age_by, :string, limit: 20, default: "Age"
    add_column :mysyg_settings, :allow_part_time, :boolean, default: true
    add_column :mysyg_settings, :allow_offsite, :boolean, default: true
    add_column :mysyg_settings, :require_medical, :boolean, default: false
  end
end
