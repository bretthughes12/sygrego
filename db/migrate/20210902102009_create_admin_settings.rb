class CreateAdminSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :settings do |t|
      t.boolean "generate_stats", default: false
      t.boolean "early_bird", default: false
      t.boolean "sports_loaded", default: false
      t.boolean "volunteers_loaded", default: false
      t.boolean "group_registrations_closed", default: false
      t.boolean "restricted_sports_allocated", default: false
      t.boolean "indiv_draws_complete", default: false
      t.boolean "team_draws_complete", default: false
      t.boolean "evening_sessions_final", default: false
      t.boolean "updates_restricted", default: false
      t.boolean "syg_is_happening", default: false
      t.boolean "syg_is_finished", default: false
      t.integer "new_group_sports_allocation_factor", default: 0
      t.integer "sport_coord_sports_allocation_factor", default: 0
      t.integer "missed_out_sports_allocation_factor", default: 0
      t.integer "small_division_ceiling", default: 20
      t.integer "medium_division_ceiling", default: 40
      t.decimal "full_fee", precision: 8, scale: 2, default: "109.0", null: false
      t.decimal "day_visitor_adjustment", precision: 8, scale: 2, default: "1.0", null: false
      t.decimal "coordinator_adjustment", precision: 8, scale: 2, default: "0.5", null: false
      t.decimal "spectator_adjustment", precision: 8, scale: 2, default: "0.77", null: false
      t.decimal "primary_age_adjustment", precision: 8, scale: 2, default: "0.0", null: false
      t.decimal "daily_adjustment", precision: 8, scale: 2, default: "0.55", null: false
      t.decimal "helper_adjustment", precision: 8, scale: 2, default: "0.55", null: false
      t.decimal "early_bird_discount", precision: 8, scale: 2, default: "10.0", null: false
      t.string "info_email", limit: 100, default: ""
      t.string "admin_email", limit: 100, default: ""
      t.string "rego_email", limit: 100, default: ""
      t.string "sports_email", limit: 100, default: ""
      t.string "sports_admin_email", limit: 100, default: ""
      t.string "ticket_email", limit: 100, default: ""
      t.string "lost_property_email", limit: 100, default: ""
      t.string "finance_email", limit: 100, default: ""
      t.string "comms_email", limit: 100, default: ""
      t.string "social_twitter_url", default: ""
      t.string "social_facebook_url", default: ""
      t.string "social_facebook_gc_url", default: ""
      t.string "social_instagram_url", default: ""
      t.string "social_youtube_url", default: ""
      t.string "social_spotify_url", default: ""
      t.string "public_website", default: ""
      t.string "rego_website", default: ""
      t.string "website_host", default: ""
      t.integer "this_year", default: 1991
      t.date "first_day_of_syg"
      t.date "early_bird_cutoff"
      t.date "deposit_due_date"
  
      t.timestamps
    end
  end
end
