class RemoveDrawTypeFromSports < ActiveRecord::Migration[7.1]
  def change
    remove_column :sports, :draw_type, :string, limit: 20, null: false
  end
end
