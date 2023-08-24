require "test_helper"

class ParticipantSignupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, 
      name: 'admin')
    FactoryBot.create(:role, 
      name: 'participant')
    @gc_role = FactoryBot.create(:role, 
      name: 'gc', 
      group_related: true)
    FactoryBot.create(:role, 
      name: 'church_rep', 
      group_related: true)
    FactoryBot.create(:user)
    @dflt_group = FactoryBot.create(:group, 
      abbr: "DFLT")
    FactoryBot.create(:mysyg_setting, 
      group_id: @dflt_group.id)
    @group = FactoryBot.create(:group)
    @ms = FactoryBot.create(:mysyg_setting, 
      group_id: @group.id)
    FactoryBot.create(:event_detail, 
      group_id: @group.id)
    @group.reload
    @tol_group = FactoryBot.create(:group)
    @tol_group.reload
    @tol_group.mysyg_setting.approve_option = "Tolerant"
    @tol_group.mysyg_setting.save
    @strict_group = FactoryBot.create(:group)
    @strict_group.reload
    @strict_group.mysyg_setting.approve_option = "Strict"
    @strict_group.mysyg_setting.save
  end

  test "should get new" do
    get new_mysyg_participant_signup_url(group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should create participant signup when group not active" do
    assert_difference('Participant.count') do
      assert_difference('User.count', 1) do
        post mysyg_participant_signups_path(
          group: @group.mysyg_setting.mysyg_name), 
          params: { 
            participant_signup: FactoryBot.attributes_for(:participant_signup, 
              group_id: @group.id) }
      end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should update an existing participant when group not active" do
    gc = FactoryBot.create(:user)
    gc.roles << @gc_role
    @group.users << gc
    @group.reload
    participant = FactoryBot.create(:participant, group_id: @group.id)

    assert_no_difference('Participant.count') do
      assert_difference('User.count', 1) do
        post mysyg_participant_signups_path(
          group: @group.mysyg_setting.mysyg_name), 
          params: {
            participant_signup: FactoryBot.attributes_for(:participant_signup, 
              first_name: participant.first_name, 
              surname: participant.surname, 
              group_id: participant.group.id ) }
      end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should create participant signup with normal option" do
    gc = FactoryBot.create(:user)
    gc.roles << @gc_role
    @group.users << gc
    @group.reload

    assert_difference('Participant.count') do
      assert_difference('User.count', 1) do
        post mysyg_participant_signups_path(
          group: @group.mysyg_setting.mysyg_name), 
          params: { 
            participant_signup: FactoryBot.attributes_for(:participant_signup, 
              group_id: @group.id) }
      end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should create participant signup with tolerant option" do
    gc = FactoryBot.create(:user)
    gc.roles << @gc_role
    @tol_group.users << gc
    @tol_group.reload

    assert_difference('Participant.count') do
      assert_difference('User.count', 1) do
        post mysyg_participant_signups_path(
          group: @tol_group.mysyg_setting.mysyg_name), 
          params: { 
            participant_signup: FactoryBot.attributes_for(:participant_signup, 
              group_id: @tol_group.id) }
      end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should create participant signup with strict option" do
    gc = FactoryBot.create(:user)
    gc.roles << @gc_role
    @strict_group.users << gc
    @strict_group.reload

    assert_difference('Participant.count') do
      assert_difference('User.count', 1) do
        post mysyg_participant_signups_path(
          group: @strict_group.mysyg_setting.mysyg_name), 
          params: { 
            participant_signup: FactoryBot.attributes_for(:participant_signup, 
              group_id: @strict_group.id) }
      end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should not create participant signup when group not found" do
    assert_no_difference('Participant.count') do
      assert_no_difference('User.count') do
        assert_raises(ActiveRecord::RecordNotFound) do
          post mysyg_participant_signups_path(
            group: "doesnotexist"), 
            params: { 
              participant_signup: FactoryBot.attributes_for(:participant_signup, 
                group_id: @dflt_group.id) }
        end
      end
    end
  end
end
