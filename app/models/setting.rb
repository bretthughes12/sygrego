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

  def method_missing(method_sym, *arguments, &block)
    APP_CONFIG.key?(method_sym) ? APP_CONFIG[method_sym] : super
  end

  def respond_to(method_sym, include_private = false)
    APP_CONFIG.key?(method_sym) ? true : super
  end
end
