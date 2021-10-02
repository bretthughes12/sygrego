class RemoveGroupIdFromRoles < ActiveRecord::Migration[6.1]
  def change
    remove_column :roles, :group_id, :integer
    add_column :roles, :group_related, :boolean, default: false
    add_column :roles, :participant_related, :boolean, default: false
  end
end
