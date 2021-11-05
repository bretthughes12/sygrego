# == Schema Information
#
# Table name: mysyg_settings
#
#  id                         :bigint           not null, primary key
#  approve_option             :string           default("Normal")
#  extra_fee_per_day          :decimal(8, 2)    default(0.0)
#  extra_fee_total            :decimal(8, 2)    default(0.0)
#  indiv_sport_view_strategy  :string           default("Show all")
#  mysyg_code                 :string(25)
#  mysyg_enabled              :boolean          default(FALSE)
#  mysyg_name                 :string(50)
#  mysyg_open                 :boolean          default(FALSE)
#  participant_instructions   :text
#  show_finance_in_mysyg      :boolean          default(TRUE)
#  show_group_extras_in_mysyg :boolean          default(TRUE)
#  show_sports_in_mysyg       :boolean          default(TRUE)
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
    mysyg_name { "MyString" }
    mysyg_enabled { false }
    mysyg_open { false }
    participant_instructions { "MyText" }
    extra_fee_total { "9.99" }
    extra_fee_per_day { "9.99" }
    show_sports_in_mysyg { false }
    show_volunteers_in_mysyg { false }
    show_finance_in_mysyg { false }
    show_group_extras_in_mysyg { false }
    approve_option { "MyString" }
    team_sport_view_strategy { "MyString" }
    indiv_sport_view_strategy { "MyString" }
    mysyg_code { "MyString" }
  end
end
