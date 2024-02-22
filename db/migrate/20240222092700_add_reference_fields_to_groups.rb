class AddReferenceFieldsToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :reference_caller, :string, limit: 20
    add_column :groups, :group_changes, :text
    add_column :groups, :ministry_goal, :text
    add_column :groups, :attendee_profile, :text
    add_column :groups, :gc_role, :text
    add_column :groups, :gc_decision, :text
    add_column :groups, :gc_years_attended_church, :integer
    add_column :groups, :gc_thoughts, :text
    add_column :groups, :reference_notes, :text
  end
end
