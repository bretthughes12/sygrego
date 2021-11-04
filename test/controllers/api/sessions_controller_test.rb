require "test_helper"

class Api::SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @session = FactoryBot.create(:session)
  end

  test "should show session via xhr" do
    get api_session_url(@session, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show session via xhr when not authorised" do
    get api_session_url(@session, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent session via xhr" do
    get api_session_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
