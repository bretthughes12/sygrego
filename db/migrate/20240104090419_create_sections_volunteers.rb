class CreateSectionsVolunteers < ActiveRecord::Migration[7.1]
  def change
    create_table :sections_volunteers, id: false do |t|
      t.references :section, null: false, foreign_key: true
      t.references :volunteer, null: false, foreign_key: true
    end
  end
end
