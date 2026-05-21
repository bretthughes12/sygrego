class AddPolicyCheckboxesToEventDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :event_details, :policy_child_safe_checked, :boolean, default: false
    add_column :event_details, :policy_code_checked, :boolean, default: false
    add_column :event_details, :policy_code_u18_checked, :boolean, default: false
    add_column :event_details, :policy_driving_checked, :boolean, default: false
    add_column :event_details, :policy_wwcc_checked, :boolean, default: false
    add_column :event_details, :policy_day_vis_checked, :boolean, default: false
    add_column :event_details, :policy_drone_checked, :boolean, default: false
    add_column :event_details, :policy_medicine_checked, :boolean, default: false
    add_column :event_details, :policy_image_use_checked, :boolean, default: false
    add_column :event_details, :policy_refund_checked, :boolean, default: false
    add_column :event_details, :policy_shower_checked, :boolean, default: false
    add_column :event_details, :policy_website_checked, :boolean, default: false
  end
end
