class AddConfigFieldsToSports < ActiveRecord::Migration[7.0]
  def change
    add_column :sports, :ladder_tie_break, :string, limit: 20, default: "Percentage"
    add_column :sports, :point_name, :string, limit: 20, default: "Point"
    add_column :sports, :allow_negative_score, :boolean, default: false
  end
end
