require "test_helper"

class Admin::SportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @sport = FactoryBot.create(:sport)

    sign_in @user
  end

  test "should get index" do
    get admin_sports_url

    assert_response :success
  end

  test "should not get index if not logged in" do
    sign_out @user

    get admin_sports_url

    assert_redirected_to new_user_session_url
  end

  test "should not get index if not an admin" do
    sign_out @user

    gc_user = FactoryBot.create(:user, :gc)
    sign_in gc_user

    get admin_sports_url

    assert_redirected_to home_gc_info_url
    assert_match /You are not authorised/, flash[:notice]
  end

  test "should download sport data" do
    get admin_sports_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show sport" do
    get admin_sport_url(@sport)

    assert_response :success
  end

  test "should not show non existent sport" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_sport_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_sport_url

    assert_response :success
  end

  test "should create sport" do
    assert_difference('Sport.count') do
      post admin_sports_path, params: { sport: FactoryBot.attributes_for(:sport) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create sport with errors" do
    assert_no_difference('Sport.count') do
      post admin_sports_path, params: { 
                                sport: FactoryBot.attributes_for(:sport,
                                  name: @sport.name) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_sport_url(@sport)

    assert_response :success
  end

  test "should update sport" do
    patch admin_sport_url(@sport), params: { sport: { name: "Bungee" } }

    assert_redirected_to admin_sports_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @sport.reload

    assert_equal "Bungee", @sport.name
  end

  test "should not update sport with errors" do
    patch admin_sport_url(@sport), params: { sport: { ladder_tie_break: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @sport.reload

    assert_not_equal "Invalid", @sport.ladder_tie_break
  end

  test "should get new import" do
    get new_import_admin_sports_url

    assert_response :success
  end

  test "should import sports" do
    file = fixture_file_upload('sport.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    assert_difference('Sport.count') do
      post import_admin_sports_url, params: { sport: { file: file }}
    end

    assert_redirected_to admin_sports_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import sports when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Sport.count') do
      post import_admin_sports_url, params: { sport: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.xlsx' format/, flash[:notice]
  end

  test "should destroy sport" do
    assert_difference("Sport.count", -1) do
      delete admin_sport_url(@sport)
    end

    assert_redirected_to admin_sports_path
  end

  test "should not destroy non existent sport" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_sport_url(12345678)
    }
  end

  test "should not destroy sport with grades" do
    FactoryBot.create(:grade, sport: @sport)

    assert_no_difference("Sport.count") do
      delete admin_sport_url(@sport)
    end

    assert_redirected_to admin_sports_path
    assert_match /Can't delete/, flash[:notice]
  end

  test "should purge the sport rules" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @sport.rules_file.attach(file)

    patch purge_file_admin_sport_url(@sport)

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @sport.reload

    assert_equal false, @sport.rules_file.attached?
  end
end
