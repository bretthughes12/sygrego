# == Schema Information
#
# Table name: sport_entries
#
#  id                   :integer          not null, primary key
#  group_id             :integer          not null
#  grade_id             :integer          not null
#  section_id           :integer
#  status               :string(20)       default("Requested")
#  team_number          :integer          default("1"), not null
#  multiple_teams       :boolean          default("false")
#  captaincy_id         :integer
#  chance_of_entry      :integer          default("100")
#  updated_by           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  preferred_section_id :integer
#
# Indexes
#
#  index_sport_entries_on_grade_id  (grade_id)
#  index_sport_entries_on_group_id  (group_id)
#

FactoryBot.define do
  factory :sport_entry do 
    grade
    status                      {"Entered"}
    group
  end
end
