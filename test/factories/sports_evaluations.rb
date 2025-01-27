# == Schema Information
#
# Table name: sports_evaluations
#
#  id               :integer          not null, primary key
#  sport            :string(20)       not null
#  section          :string(50)       not null
#  session          :string(50)       not null
#  venue_rating     :string(10)       not null
#  equipment_rating :string           not null
#  length_rating    :string           not null
#  umpiring_rating  :string           not null
#  results_rating   :string           not null
#  time_rating      :string           not null
#  support_rating   :string           not null
#  safety_rating    :string           not null
#  scoring_rating   :string           not null
#  worked_well      :text
#  to_improve       :text
#  suggestions      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_sports_evaluations_on_section  (section)
#

FactoryBot.define do
  factory :sports_evaluation do
    sport { "MyString" }
    section { "MyString" }
    session { "MyString" }
    venue_rating { "Good" }
    equipment_rating { "Good" }
    length_rating { "Good" }
    umpiring_rating { "Good" }
    results_rating { "Good" }
    time_rating { "Good" }
    support_rating { "Good" }
    safety_rating { "Good" }
    scoring_rating { "Good" }
    worked_well { "MyText" }
    to_improve { "MyText" }
    suggestions { "MyText" }
  end
end
