class CreateParticipantExtras < ActiveRecord::Migration[7.0]
  def change
    create_table :participant_extras do |t|
      t.references :participant, null: false, foreign_key: true
      t.references :group_extra, null: false, foreign_key: true
      t.boolean :wanted, default: false
      t.string :size, limit: 10
      t.string :comment, limit: 255

      t.timestamps
    end
  end
end
