class AddMoreToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :social_youtube_url, :string, default: ""
    add_column :settings, :social_spotify_url, :string, default: ""
  end
end
