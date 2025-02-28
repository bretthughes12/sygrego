# == Schema Information
#
# Table name: grades
#
#  id                      :bigint           not null, primary key
#  active                  :boolean
#  database_rowid          :integer
#  entries_to_be_allocated :integer          default(999)
#  entry_limit             :integer
#  gender_type             :string(10)       default("Open"), not null
#  grade_type              :string(10)       default("Team"), not null
#  max_age                 :integer          default(29), not null
#  max_indiv_entries_group :integer
#  max_participants        :integer          default(0), not null
#  max_team_entries_group  :integer
#  min_age                 :integer          default(11), not null
#  min_females             :integer          default(0), not null
#  min_males               :integer          default(0), not null
#  min_participants        :integer          default(0), not null
#  min_under_18s           :integer          default(0), not null
#  name                    :string(50)       not null
#  one_entry_per_group     :boolean          default(FALSE)
#  over_limit              :boolean          default(FALSE)
#  starting_entry_limit    :integer
#  status                  :string(20)       default("Open"), not null
#  team_size               :integer          default(1)
#  updated_by              :bigint
#  waitlist_expires_at     :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  sport_id                :bigint           default(0), not null
#
# Indexes
#
#  index_grades_on_name  (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (sport_id => sports.id)
#

FactoryBot.define do
  factory :grade do
    sport
    sequence(:name)             { |n| "Grade#{n}"}
    max_age                     {130}
    min_age                     {11}
    gender_type                 {"Open"}
    max_participants            {99}
    min_participants            {0}
    min_males                   {0}
    min_females                 {0}
    status                      {"Open"}
    active                      {true}
  end

  trait :restricted do
    entry_limit                 {10}
  end
end
