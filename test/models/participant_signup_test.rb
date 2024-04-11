require "test_helper"

class ParticipantSignupTest < ActiveSupport::TestCase

  def setup
    FactoryBot.create(:role, name: 'admin')
    @p_role = FactoryBot.create(:role, name: 'participant')
    @user = FactoryBot.create(:user)
    FactoryBot.create(:setting)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, group: @group)
  end

  test "should create a new participant and new user" do
    ps = ParticipantSignup.new(FactoryBot
      .attributes_for(:participant_signup, 
        group_id: @group.id))

    assert_equal true, ps.participant.new_record?
    assert_equal true, ps.user.new_record?
  end

  test "should create a new participant and update existing user" do
    user = FactoryBot.create(:user)
    user.roles << @p_role

    ps = ParticipantSignup.new(FactoryBot
      .attributes_for(:participant_signup, 
        group_id: @group.id,
        login_email: user.email))

    assert_equal true, ps.participant.new_record?
    assert_equal false, ps.user.new_record?
  end

  test "should update existing participant and create new user" do
    participant = FactoryBot.create(:participant, group: @group)

    ps = ParticipantSignup.new(FactoryBot
      .attributes_for(:participant_signup, 
        group_id: @group.id,
        first_name: participant.first_name,
        surname: participant.surname))

    assert_equal false, ps.participant.new_record?
    assert_equal true, ps.user.new_record?
  end

  test "should not save with an invalid participant" do
    ParticipantSignup.any_instance.stubs(:valid?).returns(true)

    ps = ParticipantSignup.new(FactoryBot
      .attributes_for(:participant_signup, 
        group_id: @group.id,
        age: "a"))

    assert_equal false, ps.save
  end

  test "should not save with an invalid user" do
    ParticipantSignup.any_instance.stubs(:valid?).returns(true)

    ps = ParticipantSignup.new(FactoryBot
      .attributes_for(:participant_signup, 
        group_id: @group.id,
        login_email: "a"))

    assert_equal false, ps.save
  end

  test "should add a valid voucher to a participant" do
    voucher = FactoryBot.create(:voucher)

    ps = ParticipantSignup.new(FactoryBot
      .attributes_for(:participant_signup, 
        group_id: @group.id,
        voucher_name: voucher.name))
    ps.save

    assert_equal voucher, ps.participant.voucher
  end

  test "should not be a persistant model" do
    ps = ParticipantSignup.new(FactoryBot
      .attributes_for(:participant_signup, 
        group_id: @group.id))

    assert_equal false, ps.persisted?
  end

  test "should construct the participant name" do
    ps = ParticipantSignup.new(FactoryBot
      .attributes_for(:participant_signup, 
        group_id: @group.id,
        first_name: "Jon",
        surname: "Snow"))

    assert_equal "Jon Snow", ps.name
  end
end