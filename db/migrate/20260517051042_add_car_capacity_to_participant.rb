class AddCarCapacityToParticipant < ActiveRecord::Migration[8.1]
  def change
    add_column :participants, :car_capacity, :integer
  end
end
