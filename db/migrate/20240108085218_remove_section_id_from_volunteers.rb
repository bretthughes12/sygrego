class RemoveSectionIdFromVolunteers < ActiveRecord::Migration[7.1]
  def change
    remove_column :volunteers, :section_id
  end
end
