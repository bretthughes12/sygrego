require "test_helper"

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :participant)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group_id: @group.id)
    FactoryBot.create(:event_detail, group_id: @group.id)
    @group.reload
    @participant = FactoryBot.create(:participant, group_id: @group.id)
    @user.participants << @participant
    
    sign_in @user
  end

  test "should show available participants" do
    participant = FactoryBot.create(:participant, group_id: @group.id)
    @user.participants << participant

    get available_participants_participants_url

    assert_response :success
  end

  test "should show available participants for an admin" do
    sign_out @user

    user = FactoryBot.create(:user, :admin)
    sign_in user

    get available_participants_participants_url

    assert_response :success
  end

  test "should show available participants when editing a participant" do
    participant = FactoryBot.create(:participant, group_id: @group.id)
    @user.participants << participant

    patch switch_participant_url(participant)
    assert_equal participant.id, session["current_participant"]

    get available_participants_participants_url

    assert_response :success
  end

  test "should switch participants" do
    participant = FactoryBot.create(:participant, group_id: @group.id)
    @user.participants << participant

    patch switch_participant_url(participant)

    assert_redirected_to home_mysyg_info_url(group: participant.group.mysyg_setting.mysyg_name)
    assert_equal participant.id, session["current_participant"]
  end

  test "should switch participants when an admin" do
    sign_out @user

    user = FactoryBot.create(:user, :admin)
    participant = FactoryBot.create(:participant, group_id: @group.id)
    user.participants << participant
    
    sign_in user

    patch switch_participant_url(participant)

    assert_redirected_to home_mysyg_info_url(group: participant.group.mysyg_setting.mysyg_name)
    assert_equal participant.id, session["current_participant"]
  end
end
