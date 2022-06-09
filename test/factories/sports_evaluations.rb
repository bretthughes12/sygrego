# == Schema Information
#
# Table name: sports_evaluations
#
#  id               :bigint           not null, primary key
#  equipment_rating :string           not null
#  length_rating    :string           not null
#  results_rating   :string           not null
#  safety_rating    :string           not null
#  scoring_rating   :string           not null
#  section          :string(50)       not null
#  session          :string(50)       not null
#  sport            :string(20)       not null
#  suggestions      :text
#  support_rating   :string           not null
#  time_rating      :string           not null
#  to_improve       :text
#  umpiring_rating  :string           not null
#  venue_rating     :string(10)       not null
#  worked_well      :text
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
    venue_rating { "MyString" }
    equipment_rating { "MyString" }
    length_rating { "MyString" }
    umpiring_rating { "MyString" }
    results_rating { "MyString" }
    time_rating { "MyString" }
    support_rating { "MyString" }
    safety_rating { "MyString" }
    scoring_rating { "MyString" }
    worked_well { "MyText" }
    to_improve { "MyText" }
    suggestions { "MyText" }
  end
end
