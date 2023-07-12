require "test_helper"
require 'pp'

class Sc::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :sc)

    sign_in @user
  end

  test "should get edit" do
    get edit_sc_user_url(@user)

    assert_response :success
  end

  test "should update profile" do
    patch sc_user_url(@user), params: { user: { name: "Fred Nurk" } }

    assert_redirected_to home_sc_info_url
    assert_match /Profile updated/, flash[:notice]
  
    # Reload association to fetch updated data and assert that title is updated.
    @user.reload

    assert_equal "Fred Nurk", @user.name
  end

  test "should not update user with errors" do
    patch sc_user_url(@user), params: { user: { years_as_gc: 10.5 } }

    assert_response :success
  
    # Reload association to fetch updated data and assert that title is updated.
    @user.reload

    assert_not_equal 10.5, @user.years_as_gc
  end

  test "should edit password" do
    get edit_password_sc_user_url(@user)

    assert_response :success
  end

  test "should update user password" do
    patch update_password_sc_user_url(@user), params: { user: { password: "secret", password_confirmation: "secret" } }

    assert_redirected_to home_sc_info_url
    assert_match /Password updated/, flash[:notice]
  end

  test "should not update user password with errors" do
    patch update_password_sc_user_url(@user), params: { user: { password: "secret", password_confirmation: "notsosecret" } }

    assert_response :success
  end
end
