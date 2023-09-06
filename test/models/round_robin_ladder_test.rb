require "test_helper"

class RoundRobinLadderTest < ActiveSupport::TestCase

  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @section = FactoryBot.create(:section)
  end

  test "should create a round robin ladder" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    entry4 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(@section)

    assert_equal @section.finals_format, rrl.finals_format
    assert_equal @section.number_of_groups, rrl.groups
    assert_equal @section.id, rrl.section_id
    assert_equal @section.start_court, rrl.start_court
    assert_equal 1, rrl.second_court

    assert_equal entry1.id, rrl.ladder[0][0]
    assert_equal 3, rrl.ladder[0][1].games
    assert_equal 2, rrl.ladder[0][1].wins
    assert_equal 1, rrl.ladder[0][1].forfeits
    assert_equal 4, rrl.ladder[0][1].for
    assert_equal 1, rrl.ladder[0][1].against
    assert_equal 6, rrl.ladder[0][1].points
    assert_equal 4.0, rrl.ladder[0][1].percent

    assert_equal entry4.id, rrl.ladder[1][0]
    assert_equal 3, rrl.ladder[1][1].games
    assert_equal 2, rrl.ladder[1][1].wins
    assert_equal 1, rrl.ladder[1][1].forfeits
    assert_equal 4, rrl.ladder[1][1].for
    assert_equal 3, rrl.ladder[1][1].against
    assert_equal 6, rrl.ladder[1][1].points
    assert_equal 4.0/3.0, rrl.ladder[1][1].percent

    assert_equal entry2.id, rrl.ladder[2][0]
    assert_equal 3, rrl.ladder[2][1].games
    assert_equal 0, rrl.ladder[2][1].wins
    assert_equal 1, rrl.ladder[2][1].forfeits
    assert_equal 1, rrl.ladder[2][1].draws
    assert_equal 2, rrl.ladder[2][1].for
    assert_equal 3, rrl.ladder[2][1].against
    assert_equal 3, rrl.ladder[2][1].points
    assert_equal 2.0/3.0, rrl.ladder[2][1].percent

    assert_equal entry3.id, rrl.ladder[3][0]
    assert_equal 3, rrl.ladder[3][1].games
    assert_equal 0, rrl.ladder[3][1].wins
    assert_equal 1, rrl.ladder[3][1].forfeits
    assert_equal 1, rrl.ladder[3][1].draws
    assert_equal 2, rrl.ladder[3][1].for
    assert_equal 5, rrl.ladder[3][1].against
    assert_equal 3, rrl.ladder[3][1].points
    assert_equal 2.0/5.0, rrl.ladder[3][1].percent
  end

  test "should handle negative numbers" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    entry4 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: -1,
      score_b: -1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id,
      score_a: 2,
      score_b: -1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id,
      score_a: -1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(@section)

    assert_equal @section.finals_format, rrl.finals_format
    assert_equal @section.number_of_groups, rrl.groups
    assert_equal @section.id, rrl.section_id
    assert_equal @section.start_court, rrl.start_court
    assert_equal 1, rrl.second_court

    assert_equal entry1.id, rrl.ladder[0][0]
    assert_equal 4, rrl.ladder[0][1].for
    assert_equal 0, rrl.ladder[0][1].against
    assert_equal 999.0, rrl.ladder[0][1].percent

    assert_equal entry4.id, rrl.ladder[1][0]
    assert_equal 4, rrl.ladder[1][1].for
    assert_equal 2, rrl.ladder[1][1].against
    assert_equal 4.0/2.0, rrl.ladder[1][1].percent

    assert_equal entry3.id, rrl.ladder[2][0]
    assert_equal 0, rrl.ladder[2][1].for
    assert_equal 4, rrl.ladder[2][1].against
    assert_equal 0.0/4.0, rrl.ladder[2][1].percent

    assert_equal entry2.id, rrl.ladder[3][0]
    assert_equal 0, rrl.ladder[3][1].for
    assert_equal 2, rrl.ladder[3][1].against
    assert_equal 0.0/2.0, rrl.ladder[3][1].percent
  end

  test "should calculate percentage for points difference" do
    sport = FactoryBot.create(:sport,
      ladder_tie_break: 'Point Difference')
    grade = FactoryBot.create(:grade, sport: sport)
    section = FactoryBot.create(:section, grade: grade)

    entry1 = FactoryBot.create(:sport_entry, section: section)
    entry2 = FactoryBot.create(:sport_entry, section: section)
    entry3 = FactoryBot.create(:sport_entry, section: section)
    entry4 = FactoryBot.create(:sport_entry, section: section)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(section)

    assert_equal entry1.id, rrl.ladder[0][0]
    assert_equal 3, rrl.ladder[0][1].percent

    assert_equal entry4.id, rrl.ladder[1][0]
    assert_equal 1, rrl.ladder[1][1].percent

    assert_equal entry2.id, rrl.ladder[2][0]
    assert_equal -1, rrl.ladder[2][1].percent

    assert_equal entry3.id, rrl.ladder[3][0]
    assert_equal -3, rrl.ladder[3][1].percent
  end

  test "should calculate percentage for points for" do
    sport = FactoryBot.create(:sport,
      ladder_tie_break: 'Points For')
    grade = FactoryBot.create(:grade, sport: sport)
    section = FactoryBot.create(:section, grade: grade)

    entry1 = FactoryBot.create(:sport_entry, section: section)
    entry2 = FactoryBot.create(:sport_entry, section: section)
    entry3 = FactoryBot.create(:sport_entry, section: section)
    entry4 = FactoryBot.create(:sport_entry, section: section)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(section)

    assert_equal entry4.id, rrl.ladder[0][0]
    assert_equal 4, rrl.ladder[0][1].percent

    assert_equal entry1.id, rrl.ladder[1][0]
    assert_equal 4, rrl.ladder[1][1].percent

    assert_equal entry3.id, rrl.ladder[2][0]
    assert_equal 2, rrl.ladder[2][1].percent

    assert_equal entry2.id, rrl.ladder[3][0]
    assert_equal 2, rrl.ladder[3][1].percent
  end

  test "should calculate ladder for a group" do
    section = FactoryBot.create(:section, number_of_groups: 2)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(section)

    assert_equal entry1.id, rrl.ladder_for_group(1)[0][0]
    assert_equal entry2.id, rrl.ladder_for_group(1)[1][0]
    assert_equal entry4.id, rrl.ladder_for_group(2)[0][0]
    assert_equal entry3.id, rrl.ladder_for_group(2)[1][0]

    assert_equal entry1.id, rrl.nth_in_group(1, 1)
    assert_equal entry2.id, rrl.nth_in_group(1, 2)
    assert_equal entry4.id, rrl.nth_in_group(2, 1)
    assert_equal entry3.id, rrl.nth_in_group(2, 2)
  end

  test "should calculate next best" do
    section = FactoryBot.create(:section, number_of_groups: 3)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry5 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry6 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(section)

    assert_equal entry1.id, rrl.ladder_for_group(1)[0][0]
    assert_equal entry4.id, rrl.ladder_for_group(1)[1][0]
    assert_equal entry2.id, rrl.ladder_for_group(2)[0][0]
    assert_equal entry3.id, rrl.ladder_for_group(3)[0][0]

    assert_equal entry4.id, rrl.next_best
  end
end