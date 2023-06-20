# == Schema Information
#
# Table name: round_robin_matches
#
#  id              :bigint           not null, primary key
#  complete        :boolean          default(FALSE)
#  court           :integer          default(1)
#  draw_number     :bigint
#  forfeit_a       :boolean          default(FALSE)
#  forfeit_b       :boolean          default(FALSE)
#  forfeit_umpire  :boolean          default(FALSE)
#  match           :integer
#  score_a         :integer          default(0)
#  score_b         :integer          default(0)
#  updated_by      :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  entry_a_id      :bigint
#  entry_b_id      :bigint
#  entry_umpire_id :bigint
#  section_id      :bigint
#
# Indexes
#
#  index_round_robin_matches_on_draw_number      (draw_number)
#  index_round_robin_matches_on_entry_a_id       (entry_a_id)
#  index_round_robin_matches_on_entry_b_id       (entry_b_id)
#  index_round_robin_matches_on_entry_umpire_id  (entry_umpire_id)
#  index_round_robin_matches_on_section_id       (section_id)
#
FactoryBot.define do
  factory :round_robin_match do
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
  end
end
