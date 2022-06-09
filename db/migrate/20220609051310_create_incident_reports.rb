class CreateIncidentReports < ActiveRecord::Migration[7.0]
  def change
    create_table :incident_reports do |t|
      t.string :section, limit: 50, null: false
      t.string :session, limit: 50, null: false
      t.string :venue, limit: 50, null: false
      t.text :description, null: false
      t.string :name, limit: 100, null: false
      t.text :action_taken
      t.text :other_info

      t.timestamps
    end

    add_index :incident_reports, :section
  end
end
