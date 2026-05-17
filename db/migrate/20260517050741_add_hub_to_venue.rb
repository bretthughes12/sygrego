class AddHubToVenue < ActiveRecord::Migration[8.1]
  def change
    add_column :venues, :hub, :string, limit: 50
  end
end
