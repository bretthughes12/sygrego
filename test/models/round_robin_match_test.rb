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

require "test_helper"

class RoundRobinMatchTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @section = FactoryBot.create(:section)
    @match = FactoryBot.create(:round_robin_match, section: @section)
  end

  test "should produce text for entry a" do
    entry = FactoryBot.create(:sport_entry, section: @section)
    match = FactoryBot.create(:round_robin_match, section: @section, entry_a: entry)

    assert_equal entry.group.abbr + ' 1', match.entry_a_team_text
    assert_equal '', match.entry_b_team_text
  end

  test "should produce text for entry b" do
    entry = FactoryBot.create(:sport_entry, section: @section)
    match = FactoryBot.create(:round_robin_match, section: @section, entry_b: entry)

    assert_equal entry.group.abbr + ' 1', match.entry_b_team_text
    assert_equal '', match.entry_a_team_text
  end

  test "should derive score for forfeits" do
    match1 = FactoryBot.create(:round_robin_match, :a_forfeits, section: @section, score_b: 5)
    match2 = FactoryBot.create(:round_robin_match, :b_forfeits, section: @section, score_a: 5)

    assert_equal -1, match1.import_score_a
    assert_equal 5, match1.import_score_b
    assert_equal -1, match2.import_score_b
    assert_equal 5, match2.import_score_a
  end

  test "should import round robin match from file" do
    section = FactoryBot.create(:section, id: 1, finals_format: 'Top 4', start_court: 2, number_of_groups: 2)
    entry1 = FactoryBot.create(:sport_entry, id: 111, group_number: 2)
    entry2 = FactoryBot.create(:sport_entry, id: 222, group_number: 2)
    file = fixture_file_upload('round_robin_match.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_difference('RoundRobinMatch.count') do
      @result = RoundRobinMatch.import_excel(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]

    section.reload
    assert_equal 'Top 2', section.finals_format
    assert_equal 1, section.start_court
    assert_equal 1, section.number_of_groups

    entry1.reload
    assert_equal 1, entry1.group_number

    entry2.reload
    assert_equal 1, entry2.group_number
  end

  test "should update existing round robin match from file" do
    match = FactoryBot.create(:round_robin_match, draw_number: 10322, complete: false)
    section = FactoryBot.create(:section, id: 1, finals_format: 'Top 4', start_court: 2, number_of_groups: 2)
    entry1 = FactoryBot.create(:sport_entry, id: 111, group_number: 2)
    entry2 = FactoryBot.create(:sport_entry, id: 222, group_number: 2)
    file = fixture_file_upload('round_robin_match.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('RoundRobinMatch.count') do
      @result = RoundRobinMatch.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    match.reload
    assert_equal true, match.complete

    section.reload
    assert_equal 'Top 2', section.finals_format
    assert_equal 1, section.start_court
    assert_equal 1, section.number_of_groups

    entry1.reload
    assert_equal 1, entry1.group_number

    entry2.reload
    assert_equal 1, entry2.group_number
  end

  test "should not import round robin match with errors" do
    file = fixture_file_upload('invalid_round_robin_match.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('RoundRobinMatch.count') do
      @result = RoundRobinMatch.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  # NOTE: Errors not possible with this import. 
  #       Mocha used to simulate a failure
  test "should not update round robin match with errors" do
    match = FactoryBot.create(:round_robin_match, draw_number: 1322, complete: false)
    file = fixture_file_upload('invalid_round_robin_match.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    RoundRobinMatch.any_instance.stubs(:save).returns(false)
    
    assert_no_difference('RoundRobinMatch.count') do
      @result = RoundRobinMatch.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end
end
