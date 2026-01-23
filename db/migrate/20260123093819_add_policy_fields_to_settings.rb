class AddPolicyFieldsToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :policy_child_safe_url, :string
    add_column :settings, :policy_wwcc_url, :string
    add_column :settings, :policy_conduct_url, :string
  end
end
