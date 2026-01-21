class AddDisclaimersToGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :groups, :disclaimer, :boolean, default: false
    add_column :groups, :info_acknowledgement, :boolean, default: false
    add_column :groups, :followup_requested, :boolean, default: false
  end
end
