class AddGcParticipantFlagToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :allow_gc_to_add_participants, :boolean, default: false
  end
end
