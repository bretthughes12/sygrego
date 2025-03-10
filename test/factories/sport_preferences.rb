# == Schema Information
#
# Table name: sport_preferences
#
#  id             :bigint           not null, primary key
#  level          :string(100)
#  preference     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  grade_id       :bigint
#  participant_id :bigint           not null
#  sport_id       :bigint
#
# Indexes
#
#  index_sport_preferences_on_grade_id        (grade_id)
#  index_sport_preferences_on_participant_id  (participant_id)
#  index_sport_preferences_on_sport_id        (sport_id)
#
# Foreign Keys
#
#  fk_rails_...  (participant_id => participants.id)
#

FactoryBot.define do
  factory :sport_preference do
    sport
    participant 
    preference { 1 }
  end
end
