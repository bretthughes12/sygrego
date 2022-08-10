require "test_helper"
require 'pp'

class Mysyg::UsersControllerTest < ActionDispatch::IntegrationTest
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
    get edit_mysyg_user_url(@user)

    assert_response :success
  end

  test "should update profile" do
    patch mysyg_user_url(@user, group: @group.mysyg_setting.mysyg_name), params: { user: { name: "Fred Nurk" } }

    assert_redirected_to home_mysyg_info_url(group: @participant.group.mysyg_setting.mysyg_name)
    assert_match /Profile updated/, flash[:notice]
  
    # Reload association to fetch updated data and assert that title is updated.
    @user.reload

    assert_equal "Fred Nurk", @user.name
  end

  test "should not update user with errors" do
    patch mysyg_user_url(@user), params: { user: { postcode: 10.5 } }

    assert_response :success
  
    # Reload association to fetch updated data and assert that title is updated.
    @user.reload

    assert_not_equal 10.5, @user.postcode
  end

  test "should edit password" do
    get edit_password_mysyg_user_url(@user)

    assert_response :success
  end

  test "should update user password" do
    patch update_password_mysyg_user_url(@user, group: @group.mysyg_setting.mysyg_name), params: { user: { password: "secret", password_confirmation: "secret" } }

    assert_redirected_to home_mysyg_info_url(group: @participant.group.mysyg_setting.mysyg_name)
    assert_match /Password updated/, flash[:notice]
  end

  test "should not update user password with errors" do
    patch update_password_mysyg_user_url(@user), params: { user: { password: "secret", password_confirmation: "notsosecret" } }

    assert_response :success
  end
end
