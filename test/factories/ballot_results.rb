# == Schema Information
#
# Table name: ballot_results
#
#  id                     :integer          not null, primary key
#  sport_name             :string(20)       not null
#  grade_name             :string(50)       not null
#  section_name           :string(50)
#  preferred_section_name :string(50)
#  entry_limit            :integer
#  over_limit             :boolean
#  one_entry_per_group    :boolean
#  group_name             :string(50)       not null
#  new_group              :boolean
#  sport_entry_name       :string
#  sport_entry_status     :string(20)       not null
#  factor                 :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

FactoryBot.define do
  factory :ballot_result do
    sport_name { "MyString" }
    grade_name { "MyString" }
    section_name { "MyString" }
    preferred_section_name { "MyString" }
    entry_limit { 1 }
    over_limit { false }
    one_entry_per_group { false }
    group_name { "MyString" }
    new_group { false }
    sport_entry_name { "MyString" }
    sport_entry_status { "MyString" }
    factor { 1 }
  end
end
