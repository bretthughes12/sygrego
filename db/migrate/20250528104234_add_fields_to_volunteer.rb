class AddFieldsToVolunteer < ActiveRecord::Migration[8.0]
  def change
    add_column :volunteers, :email_strategy, :string, limit: 20, default: "As defined in type"
    add_column :volunteers, :send_volunteer_email, :boolean, default: false
    add_column :volunteers, :cc_email, :string, limit: 100
    add_column :volunteers, :email_template, :string, limit: 20, default: "Default"
  end
end
