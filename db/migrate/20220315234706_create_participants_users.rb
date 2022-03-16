class CreateParticipantsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :participants_users, id: false do |t|
      t.references :participant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end
