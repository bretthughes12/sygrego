require "test_helper"

class Api::SportEntriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @sport_entry = FactoryBot.create(:sport_entry)
  end

  test "should show sport_entry via xhr" do
    get api_sport_entry_url(@sport_entry, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show sport_entry via xhr when not authorised" do
    get api_sport_entry_url(@sport_entry, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent sport_entry via xhr" do
    get api_sport_entry_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
