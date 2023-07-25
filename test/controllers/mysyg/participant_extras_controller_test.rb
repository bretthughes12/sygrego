require "test_helper"

class Mysyg::ParticipantExtrasControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :participant)
    @mysyg_setting = FactoryBot.create(:mysyg_setting)
    @group = @mysyg_setting.group
    FactoryBot.create(:event_detail, group: @group)
    @participant = FactoryBot.create(:participant, group: @group)
    @user.groups << @group
    @user.participants << @participant
    @extra1 = FactoryBot.create(:group_extra, group: @group)
    @extra2 = FactoryBot.create(:group_extra, group: @group)

    sign_in @user
  end

  test "should get index" do
    get mysyg_participant_extras_url(group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should update multiple participant extras" do
    pe1 = FactoryBot.create(:participant_extra, participant: @participant, group_extra: @extra1)
    pe2 = FactoryBot.create(:participant_extra, participant: @participant, group_extra: @extra2)

    patch update_multiple_mysyg_participant_extras_url(
      group: @group.mysyg_setting.mysyg_name,
      participant_extras: {
        pe1.id => {wanted: true, size: "L", comment: "Hello"},
        pe2.id => {wanted: false, size: "S", comment: "Goodbye"}
      }
    )

    assert_redirected_to mysyg_extras_url(group: @group.mysyg_setting.mysyg_name)
    assert_match /Updated/, flash[:notice]

    pe1.reload
    assert_equal true, pe1.wanted
    assert_equal "L", pe1.size
    assert_equal "Hello", pe1.comment
    pe2.reload
    assert_equal false, pe2.wanted
    assert_equal "S", pe2.size
    assert_equal "Goodbye", pe2.comment
  end

  test "should not update multiple participant extras with errors" do
    pe1 = FactoryBot.create(:participant_extra, participant: @participant, group_extra: @extra1)
    pe2 = FactoryBot.create(:participant_extra, participant: @participant, group_extra: @extra2)

    patch update_multiple_mysyg_participant_extras_url(
      group: @group.mysyg_setting.mysyg_name,
      participant_extras: {
        pe1.id => {wanted: true, size: "Big", comment: "Hello"},
        pe2.id => {wanted: false, size: "S", comment: "Goodbye"}
      }
    )

    assert_response :success

    pe1.reload
    assert_not_equal "Big", pe1.size
    pe2.reload
    assert_equal "S", pe2.size
  end
end
