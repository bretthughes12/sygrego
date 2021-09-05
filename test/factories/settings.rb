# == Schema Information
#
# Table name: settings
#
#  id                                   :bigint           not null, primary key
#  coordinator_adjustment               :decimal(8, 2)    default(0.5), not null
#  daily_adjustment                     :decimal(8, 2)    default(0.55), not null
#  day_visitor_adjustment               :decimal(8, 2)    default(1.0), not null
#  early_bird                           :boolean          default(FALSE)
#  early_bird_discount                  :decimal(8, 2)    default(10.0), not null
#  evening_sessions_final               :boolean          default(FALSE)
#  full_fee                             :decimal(8, 2)    default(109.0), not null
#  generate_stats                       :boolean          default(FALSE)
#  group_registrations_closed           :boolean          default(FALSE)
#  helper_adjustment                    :decimal(8, 2)    default(0.55), not null
#  indiv_draws_complete                 :boolean          default(FALSE)
#  medium_division_ceiling              :integer          default(40)
#  missed_out_sports_allocation_factor  :integer          default(0)
#  new_group_sports_allocation_factor   :integer          default(0)
#  primary_age_adjustment               :decimal(8, 2)    default(0.0), not null
#  restricted_sports_allocated          :boolean          default(FALSE)
#  small_division_ceiling               :integer          default(20)
#  spectator_adjustment                 :decimal(8, 2)    default(0.77), not null
#  sport_coord_sports_allocation_factor :integer          default(0)
#  sports_loaded                        :boolean          default(FALSE)
#  syg_is_finished                      :boolean          default(FALSE)
#  syg_is_happening                     :boolean          default(FALSE)
#  team_draws_complete                  :boolean          default(FALSE)
#  updates_restricted                   :boolean          default(FALSE)
#  volunteers_loaded                    :boolean          default(FALSE)
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
  end
end