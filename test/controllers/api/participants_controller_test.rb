require "test_helper"

class Api::ParticipantsControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @participant = FactoryBot.create(:participant)
  end

  test "should show participant via xhr" do
    get api_participant_url(@participant, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show participant via xhr when not authorised" do
    get api_participant_url(@participant, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent participant via xhr" do
    get api_participant_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
