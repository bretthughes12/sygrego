require "test_helper"

class Mysyg::ParticipantsControllerTest < ActionDispatch::IntegrationTest
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
    @participant.reload

    sign_in @user
  end

  test "should get edit" do
    get edit_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should update participant" do
    patch mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name), 
      params: { participant: { first_name: "Elvis" } }

      assert_redirected_to home_mysyg_info_url(group: @participant.group.mysyg_setting.mysyg_name)
      assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "Elvis", @participant.first_name
  end

  test "should not update participant with errors" do
    patch mysyg_participant_url(group: @group.mysyg_setting.mysyg_name, id: @participant.id), 
      params: { participant: { age: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "a", @participant.age
  end

  test "should get drivers" do
    get drivers_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should update participant driving info" do
    patch update_drivers_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name), 
      params: { participant: { driver_signature: true } }

    assert_redirected_to home_mysyg_info_url(group: @participant.group.mysyg_setting.mysyg_name)
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal true, @participant.driver_signature
  end

  test "should not update participant driving info with errors" do
    patch update_drivers_mysyg_participant_url(group: @group.mysyg_setting.mysyg_name, id: @participant.id), 
      params: { participant: { licence_type: "invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "invalid", @participant.licence_type
  end

  test "should get camping" do
    get edit_camping_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should get sports" do
    get edit_sports_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  # test "should update participant notes" do
  #   patch update_notes_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name), 
  #     params: { participant: { camping_preferences: "I camp alone" } }

  #   assert_redirected_to home_mysyg_info_url(group: @participant.group.mysyg_setting.mysyg_name)
  #   assert_match /successfully updated/, flash[:notice]

  #   # Reload association to fetch updated data and assert that title is updated.
  #   @participant.reload

  #   assert_equal "I camp alone", @participant.camping_preferences
  # end

  # test "should not update participant notes with errors" do
  #   patch update_notes_mysyg_participant_url(group: @group.mysyg_setting.mysyg_name, id: @participant.id), 
  #     params: { participant: { camping_preferences: "this is too long....--------------------....................--------------------....................-" } }

  #   assert_response :success
  #   # Reload association to fetch updated data and assert that title is updated.
  #   @participant.reload

  #   refute_match /this is too long/, @participant.camping_preferences
  # end

  test "should add a valid voucher" do
    voucher = FactoryBot.create(:voucher, name: "MYVOUCHER")

    post add_voucher_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name), params: { participant: { voucher_name: "MYVOUCHER" }}

    assert_redirected_to edit_mysyg_participant_path(group: @group.mysyg_setting.mysyg_name)
    assert_match /Voucher added/, flash[:notice]

    @participant.reload
    assert_equal voucher, @participant.voucher
  end

  test "should not add an invalid voucher" do
    post add_voucher_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name), params: { participant: { voucher_name: "NOTFOUND" }}

    assert_response :success
    assert_match /Invalid/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should not add a voucher when not sent" do
    post add_voucher_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name), params: { participant: { voucher: "NOTFOUND" }}

    assert_response :success
    assert_match /Invalid/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should delete a voucher" do
    voucher = FactoryBot.create(:voucher, name: "MYVOUCHER")
    @participant.voucher = voucher
    @participant.save

    patch delete_voucher_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name)

    assert_redirected_to edit_mysyg_participant_path(group: @group.mysyg_setting.mysyg_name)
    assert_match /Voucher deleted/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should not delete a non-existent voucher" do
    patch delete_voucher_mysyg_participant_url(@participant, group: @group.mysyg_setting.mysyg_name)

    assert_redirected_to edit_mysyg_participant_path(group: @group.mysyg_setting.mysyg_name)

    @participant.reload
    assert_nil @participant.voucher
  end
end
