class AddOrientationFlagToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :show_orientation_details, :boolean, default: true
  end
end
