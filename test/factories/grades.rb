# == Schema Information
#
# Table name: grades
#
#  id                      :integer          not null, primary key
#  database_rowid          :integer
#  sport_id                :integer          default("0"), not null
#  name                    :string(50)       not null
#  active                  :boolean
#  grade_type              :string(10)       default("Team"), not null
#  gender_type             :string(10)       default("Open"), not null
#  max_age                 :integer          default("29"), not null
#  min_age                 :integer          default("11"), not null
#  max_participants        :integer          default("0"), not null
#  min_participants        :integer          default("0"), not null
#  min_males               :integer          default("0"), not null
#  min_females             :integer          default("0"), not null
#  status                  :string(20)       default("Open"), not null
#  entry_limit             :integer
#  starting_entry_limit    :integer
#  team_size               :integer          default("1")
#  waitlist_expires_at     :datetime
#  entries_to_be_allocated :integer          default("999")
#  over_limit              :boolean
#  one_entry_per_group     :boolean
#  updated_by              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_grades_on_name  (name) UNIQUE
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
end
