require "test_helper"

class Api::ParticipantsSportEntriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @sport_entry = FactoryBot.create(:sport_entry)
    @participant1 = FactoryBot.create(:participant, group_id: @sport_entry.group_id)
    @participant2 = FactoryBot.create(:participant, group_id: @sport_entry.group_id)
    @sport_entry.participants << @participant1
    @sport_entry.participants << @participant2
  end

  test "should list all participants for a sport entry via xhr" do
    get api_sport_entry_participants_url(sport_entry_id: @sport_entry.id, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show sport_entry via xhr when not authorised" do
    get api_sport_entry_participants_url(sport_entry_id: @sport_entry.id, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent sport_entry participants via xhr" do
    get api_sport_entry_participants_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
