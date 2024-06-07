class AddSiteCheckFieldsToRegoChecklists < ActiveRecord::Migration[7.1]
  def change
    add_column :rego_checklists, :site_check_notes, :string
    add_column :rego_checklists, :site_check_completed_by, :string
    add_column :rego_checklists, :site_check_church_contact, :string
    add_column :rego_checklists, :site_check_status, :string, limit: 20, default: 'Not completed'
    add_column :rego_checklists, :site_check_completed_at, :datetime
    add_column :rego_checklists, :site_check_safety_1, :boolean, default: false
    add_column :rego_checklists, :site_check_safety_2, :boolean, default: false
    add_column :rego_checklists, :site_check_safety_3, :boolean, default: false
    add_column :rego_checklists, :site_check_safety_4, :boolean, default: false
    add_column :rego_checklists, :site_check_safety_5, :boolean, default: false
    add_column :rego_checklists, :site_check_electrical_1, :boolean, default: false
    add_column :rego_checklists, :site_check_electrical_2, :boolean, default: false
    add_column :rego_checklists, :site_check_electrical_3, :boolean, default: false
    add_column :rego_checklists, :site_check_electrical_4, :boolean, default: false
    add_column :rego_checklists, :site_check_electrical_5, :boolean, default: false
    add_column :rego_checklists, :site_check_electrical_6, :boolean, default: false
    add_column :rego_checklists, :site_check_electrical_7, :boolean, default: false
    add_column :rego_checklists, :site_check_electrical_8, :boolean, default: false
    add_column :rego_checklists, :site_check_gas_1, :boolean, default: false
    add_column :rego_checklists, :site_check_gas_2, :boolean, default: false
    add_column :rego_checklists, :site_check_fire_1, :boolean, default: false
    add_column :rego_checklists, :site_check_fire_2, :boolean, default: false
    add_column :rego_checklists, :site_check_fire_3, :boolean, default: false
    add_column :rego_checklists, :site_check_fire_4, :boolean, default: false
    add_column :rego_checklists, :site_check_flames_1, :boolean, default: false
    add_column :rego_checklists, :site_check_flames_2, :boolean, default: false
    add_column :rego_checklists, :site_check_flames_3, :boolean, default: false
    add_column :rego_checklists, :site_check_flames_4, :boolean, default: false
    add_column :rego_checklists, :site_check_flames_5, :boolean, default: false
    add_column :rego_checklists, :site_check_flames_6, :boolean, default: false
    add_column :rego_checklists, :site_check_food_1, :boolean, default: false
    add_column :rego_checklists, :site_check_food_2, :boolean, default: false
    add_column :rego_checklists, :site_check_food_3, :boolean, default: false
    add_column :rego_checklists, :site_check_site_1, :boolean, default: false
    add_column :rego_checklists, :site_check_site_2, :boolean, default: false
    add_column :rego_checklists, :site_check_medical_1, :boolean, default: false
    add_column :rego_checklists, :site_check_medical_2, :boolean, default: false
    add_column :rego_checklists, :site_check_medical_3, :boolean, default: false
    add_column :rego_checklists, :site_check_medical_4, :boolean, default: false
    add_column :rego_checklists, :site_check_medical_5, :boolean, default: false
    add_column :rego_checklists, :site_check_medical_6, :boolean, default: false
  end
end
