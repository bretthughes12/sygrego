# == Schema Information
#
# Table name: mysyg_settings
#
#  id                         :bigint           not null, primary key
#  allow_offsite              :boolean          default(TRUE)
#  allow_part_time            :boolean          default(TRUE)
#  approve_option             :string           default("Normal")
#  collect_age_by             :string(20)       default("Age")
#  extra_fee_per_day          :decimal(8, 2)    default(0.0)
#  extra_fee_total            :decimal(8, 2)    default(0.0)
#  indiv_sport_view_strategy  :string           default("Show all")
#  medicare_option            :string(10)       default("Show")
#  mysyg_code                 :string(25)
#  mysyg_enabled              :boolean          default(FALSE)
#  mysyg_name                 :string(50)
#  mysyg_open                 :boolean          default(FALSE)
#  participant_instructions   :text
#  require_emerg_contact      :boolean          default(FALSE)
#  require_medical            :boolean          default(FALSE)
#  show_finance_in_mysyg      :boolean          default(TRUE)
#  show_group_extras_in_mysyg :boolean          default(TRUE)
#  show_sports_in_mysyg       :boolean          default(TRUE)
#  show_sports_on_signup      :boolean          default(FALSE)
#  show_volunteers_in_mysyg   :boolean          default(TRUE)
#  team_sport_view_strategy   :string           default("Show all")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  group_id                   :bigint
#
# Indexes
#
#  index_mysyg_settings_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#

FactoryBot.define do
  factory :mysyg_setting do
    group

    sequence(:mysyg_name)    { |n| "test#{n}" }
    mysyg_enabled            { false }
    mysyg_open               { false }
    participant_instructions { "MyText" }
    extra_fee_total          { "0.00" }
    extra_fee_per_day        { "0.00" }
    show_sports_in_mysyg     { true }
    show_volunteers_in_mysyg { true }
    show_finance_in_mysyg    { true }
    show_group_extras_in_mysyg { true }
    approve_option           { "Normal" }
    team_sport_view_strategy { "Show all" }
    indiv_sport_view_strategy { "Show all" }
    mysyg_code               { "ABC123" }
  end

  trait :tolerant do
    approve_option           { "Tolerant" }
  end

  trait :strict do
    approve_option           { "Strict" }
  end
end
