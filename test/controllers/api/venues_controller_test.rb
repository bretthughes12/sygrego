require "test_helper"

class Api::VenuesControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @venue = FactoryBot.create(:venue)
  end

  test "should show venue via xhr" do
    get api_venue_url(@venue, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show venue via xhr when not authorised" do
    get api_venue_url(@venue, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent venue via xhr" do
    get api_venue_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
