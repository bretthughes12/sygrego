class AddBlowoutFieldsToSport < ActiveRecord::Migration[7.0]
  def change
    add_column :sports, :blowout_rule, :boolean, default: false
    add_column :sports, :forfeit_score, :integer, default: 0
  end
end
