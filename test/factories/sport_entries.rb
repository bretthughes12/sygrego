# == Schema Information
#
# Table name: sport_entries
#
#  id                   :bigint           not null, primary key
#  chance_of_entry      :integer          default(100)
#  group_number         :integer          default(1)
#  multiple_teams       :boolean          default(FALSE)
#  status               :string(20)       default("Requested")
#  team_number          :integer          default(1), not null
#  updated_by           :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  captaincy_id         :bigint
#  grade_id             :bigint           not null
#  group_id             :bigint           not null
#  preferred_section_id :bigint
#  section_id           :bigint
#
# Indexes
#
#  index_sport_entries_on_grade_id  (grade_id)
#  index_sport_entries_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (group_id => groups.id)
#

FactoryBot.define do
  factory :sport_entry do 
    grade
    status                      {"Entered"}
    group
  end
end
