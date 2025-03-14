class RemoveBonusForOfficialsFromSports < ActiveRecord::Migration[8.0]
  def change
    remove_column :sports, :bonus_for_officials, :boolean
  end
end
