# == Schema Information
#
# Table name: sport_preferences
#
#  id             :integer          not null, primary key
#  grade_id       :integer          not null
#  participant_id :integer          not null
#  preference     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_sport_preferences_on_grade_id        (grade_id)
#  index_sport_preferences_on_participant_id  (participant_id)
#

FactoryBot.define do
  factory :sport_preference do
    grade 
    participant 
    preference { 1 }
  end
end
