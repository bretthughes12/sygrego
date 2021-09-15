class AddActiveToVenues < ActiveRecord::Migration[6.1]
  def change
    add_column :venues, :active, :boolean
  end
end
