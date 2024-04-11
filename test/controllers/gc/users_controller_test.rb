require "test_helper"
require 'pp'

class Gc::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, group: @group)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @user.groups << @group
    @church_rep.groups << @group
    @participant = FactoryBot.create(:participant, group: @group)
    @participant_user = FactoryBot.create(:user, :participant)
    @participant_user.participants << @participant

    sign_in @user
  end

  test "should get index" do
    sign_out @user
    sign_in @church_rep

    get gc_users_url

    assert_response :success
  end

  test "should get new" do
    sign_out @user
    sign_in @church_rep

    get new_gc_user_url

    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post gc_users_path, params: { user: FactoryBot.attributes_for(:user) }
    end

    assert_redirected_to gc_users_url
    assert_match /created/, flash[:notice]
  end

  test "should add gc role to existing participant user" do
    assert_no_difference('User.count') do
      post gc_users_path, params: { 
        user: FactoryBot.attributes_for(:user,
        email: @participant_user.email) }
    end

    @participant_user.reload

    assert_redirected_to gc_users_url
    assert_match /GC role added/, flash[:notice]
    assert @participant_user.role?(:gc)
  end

  test "should not create user with errors" do
    assert_no_difference('User.count') do
      post gc_users_path, params: { 
        user: FactoryBot.attributes_for(:user,
        postcode: "Invalid") }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_gc_user_url(@user)

    assert_response :success
  end

  test "should update profile" do
    patch gc_user_url(@user), params: { user: { name: "Fred Nurk" } }

    assert_redirected_to home_gc_info_url
    assert_match /Profile updated/, flash[:notice]
  
    # Reload association to fetch updated data and assert that title is updated.
    @user.reload

    assert_equal "Fred Nurk", @user.name
  end

  test "should update profile as church_rep" do
    sign_out @user
    sign_in @church_rep

    patch gc_user_url(@church_rep), params: { user: { name: "Fred Nurk" } }

    assert_redirected_to home_gc_info_url
    assert_match /Profile updated/, flash[:notice]
  
    # Reload association to fetch updated data and assert that title is updated.
    @church_rep.reload

    assert_equal "Fred Nurk", @church_rep.name
  end

  test "should not update user with errors" do
    patch gc_user_url(@user), params: { user: { years_as_gc: 10.5 } }

    assert_response :success
  
    # Reload association to fetch updated data and assert that title is updated.
    @user.reload

    assert_not_equal 10.5, @user.years_as_gc
  end

  test "should edit password" do
    get edit_password_gc_user_url(@user)

    assert_response :success
  end

  test "should update user password" do
    patch update_password_gc_user_url(@user), params: { user: { password: "secret", password_confirmation: "secret" } }

    assert_redirected_to home_gc_info_url
    assert_match /Password updated/, flash[:notice]
  end

  test "should not update user password with errors" do
    patch update_password_gc_user_url(@user), params: { user: { password: "secret", password_confirmation: "notsosecret" } }

    assert_response :success
  end
end
