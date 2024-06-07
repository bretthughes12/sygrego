class AddIncidentLinkToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :incident_link, :string, default: ""
  end
end
