class DropIncidentReports < ActiveRecord::Migration[7.1]
  def change
    drop_table :incident_reports
  end
end
