class Add2025SiteCheckQuestionsToRegoChecklists < ActiveRecord::Migration[8.0]
  def change
    add_column :rego_checklists, :site_check_flames_7, :boolean
    add_column :rego_checklists, :site_check_food_4, :boolean
    add_column :rego_checklists, :site_check_medical_7, :boolean
    add_column :rego_checklists, :site_check_safety_6, :boolean
    add_column :rego_checklists, :site_check_onsite_notes, :text
  end
end
