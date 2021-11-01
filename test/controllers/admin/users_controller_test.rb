require "test_helper"
require 'pp'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    admin_role = FactoryBot.create(:role, name: 'admin')
    @user1 = FactoryBot.create(:user)
    @user = FactoryBot.create(:user)
    @user.roles << admin_role
    @user.reload

    sign_in @user
  end

  test "should get index" do
    get admin_users_url

    assert_response :success
  end

  test "should show user" do
    get admin_user_url(@user1)

    assert_response :success
  end

  test "should not show non existent user" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_user_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_user_url

    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post admin_users_path, params: { user: FactoryBot.attributes_for(:user) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create user with errors" do
    assert_no_difference('User.count') do
      post admin_users_path, params: { 
                                user: FactoryBot.attributes_for(:user,
                                email: @user1.email) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_user_url(@user1)

    assert_response :success
  end

  test "should update user" do
    patch admin_user_url(@user1), params: { user: { email: "test@example.com" } }

    assert_redirected_to admin_users_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @user1.reload

    assert_equal "test@example.com", @user1.email
  end

  test "should not update user with errors" do
    patch admin_user_url(@user1), params: { user: { email: @user.email } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @user1.reload

    assert_not_equal @user.email, @user1.email
  end

  test "should edit profile" do
    get profile_admin_user_url(@user1)

    assert_response :success
  end

  test "should update profile" do
    patch update_profile_admin_user_url(@user1), params: { user: { email: "test@example.com" } }

    assert_redirected_to admin_sports_path
    assert_match /Profile updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @user1.reload

    assert_equal "test@example.com", @user1.email
  end

  test "should not update profile with errors" do
    patch update_profile_admin_user_url(@user1), params: { user: { email: @user.email } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @user1.reload

    assert_not_equal @user.email, @user1.email
  end

  test "should edit password" do
    get edit_password_admin_user_url(@user1)

    assert_response :success
  end

  test "should update user password" do
    patch update_password_admin_user_url(@user1), params: { user: { password: "secret", password_confirmation: "secret" } }

    assert_redirected_to admin_sports_path
    assert_match /Password updated/, flash[:notice]
  end

  test "should not update user password with errors" do
    patch update_password_admin_user_url(@user1), params: { user: { password: "secret", password_confirmation: "notsosecret" } }

    assert_response :success
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete admin_user_url(@user1)
    end

    assert_redirected_to admin_users_path
  end

  test "should not destroy non existent user" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_user_url(12345678)
    }
  end
end
