require "test_helper"

class Sc::RoundRobinMatchesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :sc)
    @section = FactoryBot.create(:section)

    sign_in @user
  end

  test "should get index" do
    get sc_section_round_robin_matches_url(section_id: @section.id)

    assert_response :success
  end

  test "should update multiple round robin matches" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    entry4 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id
    )

    patch update_multiple_sc_section_round_robin_matches_url(
      section_id: @section.id,
      commit: "Update",
      round_robin_matches: {
        match1.id => {score_a: 1, score_b: 2},
        match2.id => {score_a: 2, score_b: 1},
        match3.id => {score_a: 1, score_b: 1},
        match4.id => {score_a: 'Forfeit'},
        match5.id => {score_b: 'Forfeit'},
        match6.id => {score_a: 'Forfeit', score_b: 'Forfeit'}
      }
    )

    assert_redirected_to sc_section_round_robin_matches_url(section_id: @section.id)
    assert_match /Updated/, flash[:notice]

    match1.reload
    assert_equal 1, match1.score_a
    assert_equal 2, match1.score_b
    assert_equal true, match1.complete
    match2.reload
    assert_equal 2, match2.score_a
    assert_equal 1, match2.score_b
    assert_equal true, match2.complete
    match3.reload
    assert_equal 1, match3.score_a
    assert_equal 1, match3.score_b
    assert_equal true, match3.complete
    match4.reload
    assert_equal 0, match4.score_a
    assert_equal true, match4.forfeit_a
    assert_equal 2, match4.score_b
    assert_equal false, match4.forfeit_b
    assert_equal true, match4.complete
    match5.reload
    assert_equal 2, match5.score_a
    assert_equal false, match5.forfeit_a
    assert_equal 0, match5.score_b
    assert_equal true, match5.forfeit_b
    assert_equal true, match5.complete
    match6.reload
    assert_equal 0, match6.score_a
    assert_equal true, match6.forfeit_a
    assert_equal 0, match6.score_b
    assert_equal true, match6.forfeit_b
    assert_equal true, match6.complete

  end

  test "should reset a single round robin match" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      :a_forfeits,
      section: @section,    
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id
    )
    match2 = FactoryBot.create(:round_robin_match, 
      :b_forfeits,
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry1.id
    )
    match3 = FactoryBot.create(:round_robin_match, 
      :both_forfeit,
      section: @section,
      match: 3,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id
    )

    patch update_multiple_sc_section_round_robin_matches_url(
      section_id: @section.id,
      commit: "Update",
      round_robin_matches: {
        match1.id => {score_a: 0, score_b: 0},
        match2.id => {score_a: 2, score_b: 1},
        match3.id => {score_a: 1, score_b: 1},
      }
    )

    assert_redirected_to sc_section_round_robin_matches_url(section_id: @section.id)
    assert_match /Updated/, flash[:notice]

    match1.reload
    assert_equal 0, match1.score_a
    assert_equal false, match1.forfeit_a
    assert_equal 0, match1.score_b
    assert_equal false, match1.forfeit_b
    assert_equal false, match1.complete
  end

  test "should calculate finalists for a top 2" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    entry4 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      :a_wins,
      section: @section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id
    )
    match2 = FactoryBot.create(:round_robin_match, 
      :b_wins,
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id
    )
    match3 = FactoryBot.create(:round_robin_match, 
      :draw,
      section: @section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id
    )
    match4 = FactoryBot.create(:round_robin_match, 
      :a_forfeits,
      section: @section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id
    )
    match5 = FactoryBot.create(:round_robin_match, 
      :b_forfeits,
      section: @section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id
    )
    match6 = FactoryBot.create(:round_robin_match, 
      :both_forfeit,
      section: @section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id
    )

    patch update_multiple_sc_section_round_robin_matches_url(
      section_id: @section.id,
      commit: "Calculate Finalists",
      round_robin_matches: {
        match1.id => {score_a: 2, score_b: 1},
        match2.id => {score_a: 1, score_b: 2},
        match3.id => {score_a: 1, score_b: 1},
        match4.id => {score_a: 0, score_b: 2},
        match5.id => {score_a: 2, score_b: 0},
        match6.id => {score_a: 0, score_b: 0}
      }
    )

    assert_redirected_to sc_section_round_robin_matches_url(section_id: @section.id)
    assert_match /Finalists calculated/, flash[:notice]

    gf = @section.round_robin_matches.last
    assert_equal 200, gf.match
    assert_equal entry1.id, gf.entry_a_id
    assert_equal entry4.id, gf.entry_b_id
  end

  test "should calculate finalists from semis" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    entry4 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      :a_wins,
      section: @section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id
    )
    match2 = FactoryBot.create(:round_robin_match, 
      :b_wins,
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id
    )
    match3 = FactoryBot.create(:round_robin_match, 
      :draw,
      section: @section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id
    )
    match4 = FactoryBot.create(:round_robin_match, 
      :a_forfeits,
      section: @section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id
    )
    match5 = FactoryBot.create(:round_robin_match, 
      :b_forfeits,
      section: @section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id
    )
    match6 = FactoryBot.create(:round_robin_match, 
      :both_forfeit,
      section: @section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id
    )
    sf1 = FactoryBot.create(:round_robin_match, 
      :a_wins,
      section: @section,
      match: 100,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id
    )
    sf2 = FactoryBot.create(:round_robin_match, 
      :a_wins,
      section: @section,
      match: 101,
      entry_a_id: entry4.id,
      entry_b_id: entry3.id
    )

    patch update_multiple_sc_section_round_robin_matches_url(
      section_id: @section.id,
      commit: "Calculate Finalists",
      round_robin_matches: {
        match1.id => {score_a: 2, score_b: 1},
        match2.id => {score_a: 1, score_b: 2},
        match3.id => {score_a: 1, score_b: 1},
        match4.id => {score_a: 0, score_b: 2},
        match5.id => {score_a: 2, score_b: 0},
        match6.id => {score_a: 0, score_b: 0},
        sf1.id => {score_a: 2, score_b: 1},
        sf2.id => {score_a: 2, score_b: 1}
      }
    )

    assert_redirected_to sc_section_round_robin_matches_url(section_id: @section.id)
    assert_match /Finalists calculated/, flash[:notice]

    gf = @section.round_robin_matches.last
    assert_equal 200, gf.match
    assert_equal entry1.id, gf.entry_a_id
    assert_equal entry4.id, gf.entry_b_id
  end

  test "should submit complete draw" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    entry4 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      :a_wins,
      section: @section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id
    )
    match2 = FactoryBot.create(:round_robin_match, 
      :b_wins,
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id
    )
    match3 = FactoryBot.create(:round_robin_match, 
      :draw,
      section: @section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id
    )
    match4 = FactoryBot.create(:round_robin_match, 
      :a_forfeits,
      section: @section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id
    )
    match5 = FactoryBot.create(:round_robin_match, 
      :b_forfeits,
      section: @section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id
    )
    match6 = FactoryBot.create(:round_robin_match, 
      :both_forfeit,
      section: @section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id
    )
    gf = FactoryBot.create(:round_robin_match, 
      :a_wins,
      section: @section,
      match: 200,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id
    )

    patch update_multiple_sc_section_round_robin_matches_url(
      section_id: @section.id,
      commit: "Submit",
      round_robin_matches: {
        match1.id => {score_a: 2, score_b: 1},
        match2.id => {score_a: 1, score_b: 2},
        match3.id => {score_a: 1, score_b: 1},
        match4.id => {score_a: 0, score_b: 2},
        match5.id => {score_a: 2, score_b: 0},
        match6.id => {score_a: 0, score_b: 0},
        gf.id => {score_a: 2, score_b: 1}
      }
    )

    assert_redirected_to sc_sections_url
    assert_match /Results submitted/, flash[:notice]

    @section.reload
    assert_equal true, @section.results_locked
  end

  test "should not submit incomplete draw" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    entry4 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      :a_wins,
      section: @section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id
    )
    match2 = FactoryBot.create(:round_robin_match, 
      :b_wins,
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id
    )
    match3 = FactoryBot.create(:round_robin_match, 
      :draw,
      section: @section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id
    )
    match4 = FactoryBot.create(:round_robin_match, 
      :a_forfeits,
      section: @section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id
    )
    match5 = FactoryBot.create(:round_robin_match, 
      :b_forfeits,
      section: @section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id
    )
    match6 = FactoryBot.create(:round_robin_match, 
      :both_forfeit,
      section: @section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id
    )
    gf = FactoryBot.create(:round_robin_match, 
      section: @section,
      match: 200,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id
    )

    patch update_multiple_sc_section_round_robin_matches_url(
      section_id: @section.id,
      commit: "Submit",
      round_robin_matches: {
        match1.id => {score_a: 2, score_b: 1},
        match2.id => {score_a: 1, score_b: 2},
        match3.id => {score_a: 1, score_b: 1},
        match4.id => {score_a: 0, score_b: 2},
        match5.id => {score_a: 2, score_b: 0},
        match6.id => {score_a: 0, score_b: 0},
        gf.id => {score_a: 0, score_b: 0}
      }
    )

    assert_redirected_to sc_section_round_robin_matches_url(section_id: @section.id)
    assert_match /Results not completed/, flash[:notice]
  end

  test "should get reset" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    entry3 = FactoryBot.create(:sport_entry, section: @section)
    entry4 = FactoryBot.create(:sport_entry, section: @section)
    match1 = FactoryBot.create(:round_robin_match, 
      :a_wins,
      section: @section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id
    )
    match2 = FactoryBot.create(:round_robin_match, 
      :b_wins,
      section: @section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id
    )
    match3 = FactoryBot.create(:round_robin_match, 
      :draw,
      section: @section,
      match: 3,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id
    )
    match4 = FactoryBot.create(:round_robin_match, 
      :a_forfeits,
      section: @section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id
    )
    match5 = FactoryBot.create(:round_robin_match, 
      :b_forfeits,
      section: @section,
      match: 5,
      entry_a_id: entry1.id,
      entry_b_id: entry3.id
    )
    match6 = FactoryBot.create(:round_robin_match, 
      :both_forfeit,
      section: @section,
      match: 6,
      entry_a_id: entry2.id,
      entry_b_id: entry4.id
    )

    get reset_sc_section_round_robin_matches_url(section_id: @section.id)

    assert_redirected_to sc_section_round_robin_matches_url(section_id: @section.id)
    assert_match /Results reset/, flash[:notice]

    @section.round_robin_matches.each do |m|
      assert_equal 0, m.score_a
      assert_equal 0, m.score_b
      assert_equal false, m.complete
      assert_equal false, m.forfeit_a
      assert_equal false, m.forfeit_b
    end
  end
end
