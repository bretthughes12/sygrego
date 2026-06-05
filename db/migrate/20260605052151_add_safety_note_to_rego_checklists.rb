class AddSafetyNoteToRegoChecklists < ActiveRecord::Migration[8.1]
  def change
    add_column :rego_checklists, :safety_notes, :text
  end
end
