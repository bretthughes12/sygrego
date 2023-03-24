class AddDrivingFieldsToParticipants < ActiveRecord::Migration[7.0]
  def change
    add_column :participants, :driving_to_syg, :boolean, default: false
    add_column :participants, :licence_type, :string, limit: 15
  end
end
