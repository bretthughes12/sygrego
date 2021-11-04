require "test_helper"

class Api::SportsControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @sport = FactoryBot.create(:sport)
  end

  test "should show sport via xhr" do
    get api_sport_url(@sport, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show sport via xhr when not authorised" do
    get api_sport_url(@sport, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent sport via xhr" do
    get api_sport_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
