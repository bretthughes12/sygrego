require "test_helper"

class Api::GradesControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @grade = FactoryBot.create(:grade)
  end

  test "should show grade via xhr" do
    get api_grade_url(@grade, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show grade via xhr when not authorised" do
    get api_grade_url(@grade, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent grade via xhr" do
    get api_grade_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
