# == Schema Information
#
# Table name: sport_preferences
#
#  id             :bigint           not null, primary key
#  preference     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  grade_id       :bigint           not null
#  participant_id :bigint           not null
#
# Indexes
#
#  index_sport_preferences_on_grade_id        (grade_id)
#  index_sport_preferences_on_participant_id  (participant_id)
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (participant_id => participants.id)
#
FactoryBot.define do
  factory :sport_preference do
    grade 
    participant 
    preference { 1 }
  end
end
