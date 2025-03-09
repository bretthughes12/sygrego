class CreateGroupsSportsFilters < ActiveRecord::Migration[8.0]
  def change
    create_table :groups_sports_filters do |t|
      t.references :sport, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
