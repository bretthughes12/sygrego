class Add2022FieldsToParticipants < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :rego_type, :string, limit: 10, default: "Full Time"
    add_column :participants, :vaccinated, :boolean, default: false
    add_column :participants, :vaccination_document, :string, limit: 20
    add_column :participants, :vaccination_sighted_by, :string, limit: 20
    add_column :participants, :coming_friday, :boolean, default: true
    add_column :participants, :coming_saturday, :boolean, default: true
    add_column :participants, :coming_sunday, :boolean, default: true
    add_column :participants, :coming_monday, :boolean, default: true
  end
end
