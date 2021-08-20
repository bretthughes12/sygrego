require "test_helper"
require "pp"

class Admin::SportsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @sport = FactoryBot.create(:sport,
                                lock_version: 1)
  end

  test "should get index" do
    get admin_sports_url

    assert_response :success
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
    # Reload association to fetch updated data and assert that title is updated.
    @sport.reload

    assert_equal "Bungee", @sport.name
  end

  test "should not update sport with errors" do
    patch admin_sport_url(@sport), params: { sport: { draw_type: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @sport.reload

    assert_not_equal "Invalid", @sport.draw_type
  end

  test "should not update stale sport" do
    patch admin_sport_url(@sport), params: { sport: { name: "Bungee",
                                                      lock_version: 0 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @sport.reload

    assert_not_equal "Bungee", @sport.name
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
end
