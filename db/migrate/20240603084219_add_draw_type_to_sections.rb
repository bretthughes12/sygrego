class AddDrawTypeToSections < ActiveRecord::Migration[7.1]
  def change
    add_column :sections, :draw_type, :string, limit: 20, default: "Round Robin", null: false
  end
end
