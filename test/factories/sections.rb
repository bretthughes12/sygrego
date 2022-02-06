# == Schema Information
#
# Table name: sections
#
#  id               :integer          not null, primary key
#  grade_id         :integer          default("0"), not null
#  name             :string(50)       not null
#  active           :boolean
#  venue_id         :integer          default("0"), not null
#  session_id       :integer          default("0"), not null
#  database_rowid   :integer
#  number_in_draw   :integer
#  year_introduced  :integer
#  number_of_courts :integer          default("1")
#  updated_by       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_sections_on_name  (name) UNIQUE
#

FactoryBot.define do
  factory :section do
    grade
    venue
    session
    sequence(:name)             { |n| "Section#{n}"}
    active                      {true}
  end
end
