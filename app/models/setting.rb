# == Schema Information
#
# Table name: settings
#
#  id                                   :integer          not null, primary key
#  generate_stats                       :boolean          default("false")
#  early_bird                           :boolean          default("false")
#  sports_loaded                        :boolean          default("false")
#  volunteers_loaded                    :boolean          default("false")
#  group_registrations_closed           :boolean          default("false")
#  restricted_sports_allocated          :boolean          default("false")
#  indiv_draws_complete                 :boolean          default("false")
#  team_draws_complete                  :boolean          default("false")
#  evening_sessions_final               :boolean          default("false")
#  updates_restricted                   :boolean          default("false")
#  syg_is_happening                     :boolean          default("false")
#  syg_is_finished                      :boolean          default("false")
#  new_group_sports_allocation_factor   :integer          default("0")
#  sport_coord_sports_allocation_factor :integer          default("0")
#  missed_out_sports_allocation_factor  :integer          default("0")
#  small_division_ceiling               :integer          default("20")
#  medium_division_ceiling              :integer          default("40")
#  full_fee                             :decimal(8, 2)    default("109.0"), not null
#  day_visitor_adjustment               :decimal(8, 2)    default("1.0"), not null
#  coordinator_adjustment               :decimal(8, 2)    default("0.5"), not null
#  spectator_adjustment                 :decimal(8, 2)    default("0.77"), not null
#  primary_age_adjustment               :decimal(8, 2)    default("0.0"), not null
#  daily_adjustment                     :decimal(8, 2)    default("0.55"), not null
#  helper_adjustment                    :decimal(8, 2)    default("0.55"), not null
#  early_bird_discount                  :decimal(8, 2)    default("10.0"), not null
#  info_email                           :string(100)      default("")
#  admin_email                          :string(100)      default("")
#  rego_email                           :string(100)      default("")
#  sports_email                         :string(100)      default("")
#  sports_admin_email                   :string(100)      default("")
#  ticket_email                         :string(100)      default("")
#  lost_property_email                  :string(100)      default("")
#  finance_email                        :string(100)      default("")
#  comms_email                          :string(100)      default("")
#  social_twitter_url                   :string           default("")
#  social_facebook_url                  :string           default("")
#  social_facebook_gc_url               :string           default("")
#  social_instagram_url                 :string           default("")
#  social_youtube_url                   :string           default("")
#  social_spotify_url                   :string           default("")
#  public_website                       :string           default("")
#  rego_website                         :string           default("")
#  website_host                         :string           default("")
#  this_year                            :integer          default("1991")
#  first_day_of_syg                     :date
#  early_bird_cutoff                    :date
#  deposit_due_date                     :date
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class Setting < ApplicationRecord
  validates :new_group_sports_allocation_factor,
                                           numericality: { only_integer: true },
                                           allow_blank: true
  validates :missed_out_sports_allocation_factor,
                                           numericality: { only_integer: true },
                                           allow_blank: true
  validates :sport_coord_sports_allocation_factor,
                                           numericality: { only_integer: true },
                                           allow_blank: true
  validates :small_division_ceiling,       numericality: { only_integer: true },
                                           allow_blank: true
  validates :medium_division_ceiling,      numericality: { only_integer: true },
                                           allow_blank: true
  validates :full_fee,                     numericality: true
  validates :day_visitor_adjustment,       numericality: true
  validates :coordinator_adjustment,       numericality: true
  validates :spectator_adjustment,         numericality: true
  validates :primary_age_adjustment,       numericality: true
  validates :daily_adjustment,             numericality: true
  validates :early_bird_discount,          numericality: true
  validates :helper_adjustment,            numericality: true
  validates :this_year,                    numericality: { only_integer: true }
  validates :info_email,                   length: { maximum: 100 }
  validates :admin_email,                  length: { maximum: 100 }
  validates :rego_email,                   length: { maximum: 100 }
  validates :sports_email,                 length: { maximum: 100 }
  validates :sports_admin_email,           length: { maximum: 100 }
  validates :ticket_email,                 length: { maximum: 100 }
  validates :lost_property_email,          length: { maximum: 100 }
  validates :finance_email,                length: { maximum: 100 }
  validates :comms_email,                  length: { maximum: 100 }

  def method_missing(method_sym, *arguments, &block)
    APP_CONFIG.key?(method_sym) ? APP_CONFIG[method_sym] : super
  end

  def respond_to(method_sym, include_private = false)
    APP_CONFIG.key?(method_sym) ? true : super
  end
end
