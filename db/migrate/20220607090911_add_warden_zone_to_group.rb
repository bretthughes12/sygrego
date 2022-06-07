class AddWardenZoneToGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :event_details, :warden_zone_id, :bigint
  end
end
