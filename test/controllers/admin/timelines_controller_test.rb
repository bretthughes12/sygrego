require "test_helper"

class Admin::TimelinesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @timeline = FactoryBot.create(:timeline)

    sign_in @user
  end

  test "should get index" do
    get admin_timelines_url

    assert_response :success
  end

  test "should not get index if not logged in" do
    sign_out @user

    get admin_timelines_url

    assert_redirected_to new_user_session_url
  end

  test "should not get index if not an admin" do
    sign_out @user

    gc_user = FactoryBot.create(:user, :gc)
    sign_in gc_user

    get admin_timelines_url

    assert_redirected_to home_gc_info_url
    assert_match /You are not authorised/, flash[:notice]
  end

  test "should show timeline" do
    get admin_timeline_url(@timeline)

    assert_response :success
  end

  test "should not show non existent timeline" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_timeline_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_timeline_url

    assert_response :success
  end

  test "should create timeline" do
    assert_difference('Timeline.count') do
      post admin_timelines_path, params: { timeline: FactoryBot.attributes_for(:timeline) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create timeline with errors" do
    assert_no_difference('Timeline.count') do
      post admin_timelines_path, params: { 
                                timeline: FactoryBot.attributes_for(:timeline,
                                  name: "This name is too long---------++++++++++----------+") }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_timeline_url(@timeline)

    assert_response :success
  end

  test "should update timeline" do
    patch admin_timeline_url(@timeline), params: { timeline: { name: "Deadline" } }

    assert_redirected_to admin_timelines_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @timeline.reload

    assert_equal "Deadline", @timeline.name
  end

  test "should not update timeline with errors" do
    patch admin_timeline_url(@timeline), params: { timeline: { 
      name: "This name is too long---------++++++++++----------+" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @timeline.reload

    assert_not_equal "This name is too long---------++++++++++----------+", @timeline.name
  end

  test "should destroy timeline" do
    assert_difference("Timeline.count", -1) do
      delete admin_timeline_url(@timeline)
    end

    assert_redirected_to admin_timelines_path
  end

  test "should not destroy non existent timeline" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_timeline_url(12345678)
    }
  end
end
