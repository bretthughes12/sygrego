class AddDisclaimerFieldsToGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :groups, :ccvt_child_safe_disclaimer, :boolean, default: false
    add_column :groups, :wwcc_policy_disclaimer, :boolean, default: false
    add_column :groups, :conduct_disclaimer, :boolean, default: false
    add_column :groups, :group_child_safe_disclaimer, :boolean, default: false
  end
end
