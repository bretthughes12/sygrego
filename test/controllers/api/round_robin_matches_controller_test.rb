require "test_helper"

class Api::RoundRobinMatchesControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @round_robin_match = FactoryBot.create(:round_robin_match)
  end

  test "should show round_robin_match via xhr" do
    get api_round_robin_match_url(@round_robin_match, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show round_robin_match via xhr when not authorised" do
    get api_round_robin_match_url(@round_robin_match, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent round_robin_match via xhr" do
    get api_round_robin_match_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
