class AddUmpireTextToSport < ActiveRecord::Migration[8.1]
  def change
    add_column :sports, :umpire_text, :string, limit: 20, default: 'Umpire'
  end
end
