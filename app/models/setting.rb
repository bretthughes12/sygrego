# == Schema Information
#
# Table name: settings
#
#  id                                   :bigint           not null, primary key
#  admin_email                          :string(100)      default("")
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

class Setting < ApplicationRecord
  attr_reader :knockout_file
  attr_reader :ladder_file
  attr_reader :results_file

  has_one_attached :knockout_reference
  has_one_attached :ladder_reference
  has_one_attached :results_reference

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
