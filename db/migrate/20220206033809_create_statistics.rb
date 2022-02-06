class CreateStatistics < ActiveRecord::Migration[7.0]
  def change
    create_table :statistics do |t|
      t.integer :number_of_groups
      t.integer :number_of_participants
      t.integer :number_of_sport_entries
      t.integer :number_of_volunteer_vacancies
      t.integer :weeks_to_syg

      t.timestamps
    end
  end
end
