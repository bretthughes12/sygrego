# == Schema Information
#
# Table name: mysyg_settings
#
#  id                         :integer          not null, primary key
#  mysyg_name                 :string(50)
#  mysyg_enabled              :boolean          default("false")
#  mysyg_open                 :boolean          default("false")
#  participant_instructions   :text
#  extra_fee_total            :decimal(8, 2)    default("0.0")
#  extra_fee_per_day          :decimal(8, 2)    default("0.0")
#  show_sports_in_mysyg       :boolean          default("true")
#  show_volunteers_in_mysyg   :boolean          default("true")
#  show_finance_in_mysyg      :boolean          default("true")
#  show_group_extras_in_mysyg :boolean          default("true")
#  approve_option             :string           default("Normal")
#  team_sport_view_strategy   :string           default("Show all")
#  indiv_sport_view_strategy  :string           default("Show all")
#  mysyg_code                 :string(25)
#  group_id                   :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_mysyg_settings_on_group_id  (group_id)
#

FactoryBot.define do
  factory :mysyg_setting do
    group

    sequence(:mysyg_name)  { |n| "test#{n}" }
    mysyg_enabled { false }
    mysyg_open { false }
    participant_instructions { "MyText" }
    extra_fee_total { "0.00" }
    extra_fee_per_day { "0.00" }
    show_sports_in_mysyg { true }
    show_volunteers_in_mysyg { true }
    show_finance_in_mysyg { true }
    show_group_extras_in_mysyg { true }
    approve_option { "Normal" }
    team_sport_view_strategy { "Show all" }
    indiv_sport_view_strategy { "Show all" }
    mysyg_code { "ABC123" }
  end
end
