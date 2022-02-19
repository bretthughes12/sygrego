require "test_helper"

class Api::VolunteerTypesControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @volunteer_type = FactoryBot.create(:volunteer_type)
  end

  test "should show volunteer_type via xhr" do
    get api_volunteer_type_url(@volunteer_type, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show volunteer_type via xhr when not authorised" do
    get api_volunteer_type_url(@volunteer_type, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent volunteer_type via xhr" do
    get api_volunteer_type_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
