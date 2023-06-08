# == Schema Information
#
# Table name: sport_result_entries
#
#  id              :bigint           not null, primary key
#  blowout_rule    :boolean
#  complete        :boolean          default(FALSE)
#  court           :integer
#  finals_format   :string
#  forfeit_a       :boolean          default(FALSE)
#  forfeit_b       :boolean          default(FALSE)
#  forfeit_score   :integer
#  forfeit_umpire  :boolean          default(FALSE)
#  groups          :integer
#  match           :integer
#  score_a         :integer          default(0)
#  score_b         :integer          default(0)
#  start_court     :integer
#  team_a          :integer
#  team_b          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  entry_a_id      :bigint
#  entry_b_id      :bigint
#  entry_umpire_id :bigint
#  section_id      :bigint
#
# Indexes
#
#  index_sport_result_entries_on_entry_a_id       (entry_a_id)
#  index_sport_result_entries_on_entry_b_id       (entry_b_id)
#  index_sport_result_entries_on_entry_umpire_id  (entry_umpire_id)
#  index_sport_result_entries_on_section_id       (section_id)
#
FactoryBot.define do
  factory :sport_result_entry do
    section
    court { 1 }
    match { 1 }
    complete { false }
    entry_a_id { 1 }
    team_a { 1 }
    score_a { 1 }
    entry_b_id { 1 }
    team_b { 1 }
    score_b { 1 }
    forfeit_a { false }
    forfeit_b { false }
    entry_umpire_id { 1 }
    forfeit_umpire { false }
    blowout_rule { false }
    forfeit_score { 1 }
    groups { 1 }
    finals_format { "MyString" }
    start_court { 1 }
  end
end
