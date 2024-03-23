require "test_helper"

class Admin::VenuesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @venue = FactoryBot.create(:venue)

    sign_in @user
  end

  test "should get index" do
    get admin_venues_url

    assert_response :success
  end

  test "should download venue data" do
    get admin_venues_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show venue" do
    get admin_venue_url(@venue)

    assert_response :success
  end

  test "should not show non existent venue" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_venue_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_venue_url

    assert_response :success
  end

  test "should create venue" do
    assert_difference('Venue.count') do
      post admin_venues_path, params: { venue: FactoryBot.attributes_for(:venue) }
    end

    assert_response :success
    assert_match(/successfully created/, flash[:notice])
  end

  test "should not create venue with errors" do
    assert_no_difference('Venue.count') do
      post admin_venues_path, params: { 
                                venue: FactoryBot.attributes_for(:venue,
                                  name: @venue.name) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_venue_url(@venue)

    assert_response :success
  end

  test "should update venue" do
    patch admin_venue_url(@venue), params: { venue: { name: "MCG" } }

    assert_redirected_to admin_venues_path
    assert_match(/successfully updated/, flash[:notice])

    # Reload association to fetch updated data and assert that title is updated.
    @venue.reload

    assert_equal "MCG", @venue.name
  end

  test "should not update venue with errors" do
    patch admin_venue_url(@venue), params: { venue: { database_code: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @venue.reload

    assert_not_equal "Invalid", @venue.database_code
  end

  test "should get new import" do
    get new_import_admin_venues_url

    assert_response :success
  end

  test "should import venues" do
    file = fixture_file_upload('venue.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    assert_difference('Venue.count') do
      post import_admin_venues_url, params: { venue: { file: file }}
    end

    assert_redirected_to admin_venues_path 
    assert_match(/upload complete/, flash[:notice])
  end

  test "should not import venues when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Venue.count') do
      post import_admin_venues_url, params: { venue: { file: file }}
    end

    assert_response :success
    assert_match(/must be in '\.xlsx' format/, flash[:notice])
  end

  test "should destroy venue" do
    assert_difference("Venue.count", -1) do
      delete admin_venue_url(@venue)
    end

    assert_redirected_to admin_venues_path
  end

  test "should not destroy non existent venue" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_venue_url(12345678)
    }
  end

  test "should not destroy venue with sections" do
    FactoryBot.create(:section, venue: @venue)

    assert_no_difference("Venue.count") do
      delete admin_venue_url(@venue)
    end

    assert_redirected_to admin_venues_path
    assert_match(/Can't delete/, flash[:notice])
  end
end
