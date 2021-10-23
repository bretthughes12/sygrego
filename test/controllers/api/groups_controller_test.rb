require "test_helper"

class Api::GroupsControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
  end

  test "should show group via xhr" do
    get api_group_url(@group, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show group via xhr when not authorised" do
    get api_group_url(@group, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent group via xhr" do
    get api_group_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
