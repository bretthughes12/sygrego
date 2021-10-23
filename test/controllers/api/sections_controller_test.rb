require "test_helper"

class Api::SectionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @section = FactoryBot.create(:section)
  end

  test "should show section via xhr" do
    get api_section_url(@section, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show section via xhr when not authorised" do
    get api_section_url(@section, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent section via xhr" do
    get api_section_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
