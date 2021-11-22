class CreateRegoChecklists < ActiveRecord::Migration[6.1]
  def change
    create_table :rego_checklists do |t|
      t.boolean :registered, default: false
      t.string :rego_rep, limit: 40
      t.string :rego_mobile, limit: 30
      t.string :admin_rep, limit: 40
      t.string :second_rep, limit: 40
      t.string :second_mobile, limit: 30
      t.boolean :disabled_participants, default: false
      t.text :disabled_notes
      t.boolean :driver_form, default: false
      t.text :finance_notes
      t.text :sport_notes

      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
