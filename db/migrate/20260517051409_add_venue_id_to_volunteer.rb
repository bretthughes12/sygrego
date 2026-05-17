class AddVenueIdToVolunteer < ActiveRecord::Migration[8.1]
  def change
    add_column :volunteers, :venue_id, :bigint
  end
end
