class AddMorePolicyLinksToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :policy_day_visitor_url, :string
    add_column :settings, :policy_driving_url, :string
    add_column :settings, :policy_drone_use_url, :string
    add_column :settings, :policy_medicine_url, :string
    add_column :settings, :policy_image_use_url, :string
    add_column :settings, :policy_refund_url, :string
  end
end
