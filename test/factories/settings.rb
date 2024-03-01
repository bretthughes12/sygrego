# == Schema Information
#
# Table name: settings
#
#  id                                   :bigint           not null, primary key
#  admin_email                          :string(100)      default("")
#  allow_gc_to_add_participants         :boolean          default(FALSE)
#  comms_email                          :string(100)      default("")
#  coordinator_adjustment               :decimal(8, 2)    default(0.5), not null
#  daily_adjustment                     :decimal(8, 2)    default(0.55), not null
#  day_visitor_adjustment               :decimal(8, 2)    default(1.0), not null
#  deposit_due_date                     :date
#  early_bird                           :boolean          default(FALSE)
#  early_bird_cutoff                    :date
#  early_bird_discount                  :decimal(8, 2)    default(10.0), not null
#  evening_sessions_final               :boolean          default(FALSE)
#  finance_email                        :string(100)      default("")
#  first_day_of_syg                     :date
#  full_fee                             :decimal(8, 2)    default(109.0), not null
#  generate_stats                       :boolean          default(FALSE)
#  group_registrations_closed           :boolean          default(FALSE)
#  helper_adjustment                    :decimal(8, 2)    default(0.55), not null
#  indiv_draws_complete                 :boolean          default(FALSE)
#  info_email                           :string(100)      default("")
#  lost_property_email                  :string(100)      default("")
#  medium_division_ceiling              :integer          default(40)
#  missed_out_sports_allocation_factor  :integer          default(0)
#  new_group_sports_allocation_factor   :integer          default(0)
#  participant_registrations_closed     :boolean          default(FALSE)
#  primary_age_adjustment               :decimal(8, 2)    default(0.0), not null
#  public_website                       :string           default("")
#  rego_email                           :string(100)      default("")
#  rego_website                         :string           default("")
#  restricted_sports_allocated          :boolean          default(FALSE)
#  small_division_ceiling               :integer          default(20)
#  social_facebook_gc_url               :string           default("")
#  social_facebook_url                  :string           default("")
#  social_instagram_url                 :string           default("")
#  social_spotify_url                   :string           default("")
#  social_twitter_url                   :string           default("")
#  social_youtube_url                   :string           default("")
#  spectator_adjustment                 :decimal(8, 2)    default(0.77), not null
#  sport_coord_sports_allocation_factor :integer          default(0)
#  sports_admin_email                   :string(100)      default("")
#  sports_email                         :string(100)      default("")
#  sports_loaded                        :boolean          default(FALSE)
#  syg_is_finished                      :boolean          default(FALSE)
#  syg_is_happening                     :boolean          default(FALSE)
#  team_draws_complete                  :boolean          default(FALSE)
#  this_year                            :integer          default(1991)
#  ticket_email                         :string(100)      default("")
#  updates_restricted                   :boolean          default(FALSE)
#  volunteers_loaded                    :boolean          default(FALSE)
#  website_host                         :string           default("")
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

FactoryBot.define do
  factory :setting do
    group_registrations_closed  { false }
    restricted_sports_allocated { false }
    syg_is_happening            { false }
    syg_is_finished             { false }
    indiv_draws_complete        { false }
    team_draws_complete         { false }
    full_fee                    { 80.0 }
    early_bird_discount         { 5.0 }
    day_visitor_adjustment      { 0.6 }
    coordinator_adjustment      { 0.75 }
    spectator_adjustment        { 0.57 }
    primary_age_adjustment      { 0.33 }
    daily_adjustment            { 0.43 }
    info_email                  { "info@stateyouthgames.com" }
    admin_email                 { "admin@stateyouthgames.com" }
    rego_email                  { "rego@stateyouthgames.com" }
    sports_email                { "sports@stateyouthgames.com" }
    sports_admin_email          { "sports_admin@stateyouthgames.com" }
    ticket_email                { "ticket@stateyouthgames.com" }
    lost_property_email         { "lost_property@stateyouthgames.com" }
    finance_email               { "finance@stateyouthgames.com" }
    comms_email                 { "comms@stateyouthgames.com" }
    social_twitter_url          { "https://twitter.com/syg" }
    social_facebook_url         { "https://facebook.com/syg" }
    social_facebook_gc_url      { "https://facebook.com/syg_gc" }
    social_instagram_url        { "https://instagram.com/syg" }
    public_website              { "https://stateyouthgames.com" }
    rego_website                { "https://sygrego.com" }
    website_host                { "sygrego.com" }
    this_year                   { 2020 }
    first_day_of_syg            { "08/06/2020" }
    early_bird_cutoff           { "08/04/2020" }
    deposit_due_date            { "08/05/2020" }
  end
end
