require "test_helper"

class Admin::RoundRobinMatchesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @section = FactoryBot.create(:section)
    @match = FactoryBot.create(:round_robin_match, section: @section)

    sign_in @user
  end

  test "should get index" do
    entry1 = FactoryBot.create(:sport_entry, section: @section)
    entry2 = FactoryBot.create(:sport_entry, section: @section)
    @match.entry_a = entry1
    @match.entry_b = entry2
    @match.save

    get admin_section_round_robin_matches_url(section_id: @section.id)

    assert_response :success
  end

  test "should not get index if not logged in" do
    sign_out @user

    get admin_section_round_robin_matches_url(section_id: @section.id)

    assert_redirected_to new_user_session_url
  end

  test "should not get index if not an admin" do
    sign_out @user

    gc_user = FactoryBot.create(:user, :gc)
    sign_in gc_user

    get admin_section_round_robin_matches_url(section_id: @section.id)

    assert_redirected_to home_gc_info_url
    assert_match /You are not authorised/, flash[:notice]
  end

  test "should download round robin matches" do
    get matches_admin_round_robin_matches_url(section_id: @section.id, format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should get new import" do
    get new_import_admin_round_robin_matches_url

    assert_response :success
  end

  test "should import round robin matches" do
    section = FactoryBot.create(:section, id: 1, finals_format: 'Top 4', start_court: 2, number_of_groups: 2)
    entry1 = FactoryBot.create(:sport_entry, id: 111, group_number: 2)
    entry2 = FactoryBot.create(:sport_entry, id: 222, group_number: 2)
    file = fixture_file_upload('round_robin_match.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    assert_difference('RoundRobinMatch.count') do
      post import_admin_round_robin_matches_url, params: { round_robin_match: { file: file }}
    end

    assert_redirected_to results_admin_sections_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import round robin matches when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('RoundRobinMatch.count') do
      post import_admin_round_robin_matches_url, params: { round_robin_match: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.xlsx' format/, flash[:notice]
  end
end
