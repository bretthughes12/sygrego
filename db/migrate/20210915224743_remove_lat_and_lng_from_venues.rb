class RemoveLatAndLngFromVenues < ActiveRecord::Migration[6.1]
  def change
    remove_column :venues, :lat
    remove_column :venues, :lng
  end
end
