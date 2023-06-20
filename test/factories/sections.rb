# == Schema Information
#
# Table name: sections
#
#  id               :bigint           not null, primary key
#  active           :boolean
#  database_rowid   :integer
#  finals_format    :string(20)
#  name             :string(50)       not null
#  number_in_draw   :integer
#  number_of_courts :integer          default(1)
#  number_of_groups :integer          default(1)
#  results_locked   :boolean          default(FALSE)
#  start_court      :integer          default(1)
#  updated_by       :bigint
#  year_introduced  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  grade_id         :bigint           default(0), not null
#  session_id       :bigint           default(0), not null
#  venue_id         :bigint           default(0), not null
#
# Indexes
#
#  index_sections_on_name  (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (session_id => sessions.id)
#  fk_rails_...  (venue_id => venues.id)
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
