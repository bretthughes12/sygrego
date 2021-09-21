class AddFieldsToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :info_email, :string, default: "", limit:100
    add_column :settings, :admin_email, :string, default: "", limit:100
    add_column :settings, :rego_email, :string, default: "", limit:100
    add_column :settings, :sports_email, :string, default: "", limit:100
    add_column :settings, :sports_admin_email, :string, default: "", limit:100
    add_column :settings, :ticket_email, :string, default: "", limit:100
    add_column :settings, :lost_property_email, :string, default: "", limit:100
    add_column :settings, :finance_email, :string, default: "", limit:100
    add_column :settings, :comms_email, :string, default: "", limit:100
    add_column :settings, :social_twitter_url, :string, default: ""
    add_column :settings, :social_facebook_url, :string, default: ""
    add_column :settings, :social_facebook_gc_url, :string, default: ""
    add_column :settings, :social_instagram_url, :string, default: ""
    add_column :settings, :public_website, :string, default: ""
    add_column :settings, :rego_website, :string, default: ""
    add_column :settings, :website_host, :string, default: ""
    add_column :settings, :this_year, :integer, default: 1991
    add_column :settings, :first_day_of_syg, :date
    add_column :settings, :early_bird_cutoff, :date
    add_column :settings, :deposit_due_date, :date
  end
end
