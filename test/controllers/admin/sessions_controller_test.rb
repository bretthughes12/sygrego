require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user)
    @session = FactoryBot.create(:session)
    sign_in @user
  end

  test "should get index" do
    get admin_sessions_url

    assert_response :success
  end

  test "should download session data" do
    get admin_sessions_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show session" do
    get admin_session_url(@session)

    assert_response :success
  end

  test "should not show non existent session" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_session_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_session_url

    assert_response :success
  end

  test "should create session" do
    assert_difference('Session.count') do
      post admin_sessions_path, params: { session: FactoryBot.attributes_for(:session) }
    end

    assert_response :success
  end

  test "should not create session with errors" do
    assert_no_difference('Session.count') do
      post admin_sessions_path, params: { 
                                session: FactoryBot.attributes_for(:session,
                                  name: @session.name) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_session_url(@session)

    assert_response :success
  end

  test "should update session" do
    patch admin_session_url(@session), params: { session: { name: "Friday Evening" } }

    assert_redirected_to admin_sessions_path
    # Reload association to fetch updated data and assert that title is updated.
    @session.reload

    assert_equal "Friday Evening", @session.name
  end

  test "should not update session with errors" do
    patch admin_session_url(@session), params: { session: { name: "Too Long...................................................." } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @session.reload

    assert_not_equal "Too Long....................................................", @session.name
  end

  test "should destroy session" do
    assert_difference("Session.count", -1) do
      delete admin_session_url(@session)
    end

    assert_redirected_to admin_sessions_path
  end

  test "should not destroy non existent session" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_session_url(12345678)
    }
  end

  test "should show session via xhr" do
    sign_out @user

    get admin_session_url(@session, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show session via xhr when not authorised" do
    sign_out @user

    get admin_session_url(@session, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent session via xhr" do
    sign_out @user

    get admin_session_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
