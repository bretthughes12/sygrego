class AddFlagToSettings < ActiveRecord::Migration[7.0]
  def change
   add_column :settings, :participant_registrations_closed, :boolean, default: false
  end
end
