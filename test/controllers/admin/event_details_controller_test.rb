require "test_helper"

class Admin::EventDetailsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @event_detail = FactoryBot.create(:event_detail)
    
    sign_in @user
  end

  test "should get index" do
    get admin_event_details_url

    assert_response :success
  end

  test "should search event details" do
    get search_admin_event_details_url

    assert_response :success
  end

  test "should download event detail data" do
    get admin_event_details_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show event_detail" do
    get admin_event_detail_url(@event_detail)

    assert_response :success
  end

  test "should not show non existent event_detail" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_event_detail_url(12345678)
    }
  end

  test "should get edit" do
    get edit_admin_event_detail_url(@event_detail)

    assert_response :success
  end

  test "should update event detail" do
    patch admin_event_detail_url(@event_detail), params: { event_detail: { estimated_numbers: 24 } }

    assert_redirected_to admin_event_details_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal 24, @event_detail.estimated_numbers
  end

  test "should not update event detail with errors" do
    patch admin_event_detail_url(@event_detail), params: { event_detail: { buddy_interest: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_not_equal "a", @event_detail.buddy_interest
  end

  test "should get new import" do
    get new_import_admin_event_details_url

    assert_response :success
  end

  test "should import event details" do
    group = FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('event_detail.csv','application/csv')

    assert_no_difference('EventDetail.count') do
      post import_admin_event_details_url, params: { event_detail: { file: file }}
    end

    assert_redirected_to admin_event_details_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import event_details when the file is not csv" do
    group = FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('EventDetail.count') do
      post import_admin_event_details_url, params: { event_detail: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
  end

  test "should purge the food cert from event details" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @event_detail.food_cert.attach(file)

    patch purge_file_admin_event_detail_url(@event_detail)

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal false, @event_detail.food_cert.attached?
  end
end
