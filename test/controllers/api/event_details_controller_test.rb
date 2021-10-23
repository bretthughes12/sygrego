require "test_helper"

class Api::EventDetailsControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @event_detail = FactoryBot.create(:event_detail)
  end

  test "should show event_detail via xhr" do
    get api_event_detail_url(@event_detail, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show event_detail via xhr when not authorised" do
    get api_event_detail_url(@event_detail, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent event_detail via xhr" do
    get api_event_detail_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
