class Add2022FieldsToRegoChecklists < ActiveRecord::Migration[7.0]
  def change
    add_column :rego_checklists, :covid_plan_sighted, :boolean, default: false
    add_column :rego_checklists, :food_cert_sighted, :boolean, default: false
    add_column :rego_checklists, :insurance_sighted, :boolean, default: false
    add_column :rego_checklists, :upload_notes, :text
    add_column :rego_checklists, :driving_notes, :text
  end
end
