require "test_helper"

class ParticipantSignupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    FactoryBot.create(:role, name: 'participant')
    FactoryBot.create(:role, name: 'gc', group_related: true)
    FactoryBot.create(:role, name: 'church_rep', group_related: true)
    FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group_id: @group.id)
    FactoryBot.create(:event_detail, group_id: @group.id)
    @group.reload
  end

  test "should get new" do
    get new_mysyg_participant_signup_url(group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should create participant signup" do
    assert_difference('Participant.count') do
        assert_difference('User.count', 1) do
            post mysyg_participant_signups_path(group: @group.mysyg_setting.mysyg_name), params: { participant_signup: FactoryBot.attributes_for(:participant_signup, group_id: @group.id) }
        end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should update an existing participant" do
    participant = FactoryBot.create(:participant, group_id: @group.id)

    assert_no_difference('Participant.count') do
        assert_difference('User.count', 1) do
            post mysyg_participant_signups_path(group: @group.mysyg_setting.mysyg_name), params: { participant_signup: FactoryBot.attributes_for(:participant_signup, first_name: participant.first_name, surname: participant.surname, group_id: participant.group.id ) }
        end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

#  test "should not create a participant signup with errors on group" do
#    assert_no_difference('Participant.count') do
#        assert_no_difference('User.count') do
#            post participant_signups_path, params: { participant_signup: FactoryBot.attributes_for(:participant_signup, email: "A") }
#        end
#    end

#    assert_response :success
#    assert_match /There was a problem/, flash[:notice]
#  end

#  test "should not create a participant signup with errors on church_rep" do
#    assert_no_difference('Participant.count') do
#        assert_no_difference('User.count') do
#            post participant_signups_path, params: { participant_signup: FactoryBot.attributes_for(:participant_signup, church_rep_email: "A") }
#        end
#    end

#    assert_response :success
#    assert_match /There was a problem/, flash[:notice]
#  end
end
