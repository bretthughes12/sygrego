class AddOrientationDetailsIdToEventDetails < ActiveRecord::Migration[8.0]
  def change
    add_reference :event_details, :orientation_detail, foreign_key: true
  end
end
