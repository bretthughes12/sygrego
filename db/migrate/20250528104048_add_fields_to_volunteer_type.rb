class AddFieldsToVolunteerType < ActiveRecord::Migration[8.0]
  def change
    add_column :volunteer_types, :send_volunteer_email, :boolean, default: false
    add_column :volunteer_types, :cc_email, :string, limit: 100
    add_column :volunteer_types, :email_template, :string, limit: 20, default: "Default"
  end
end
