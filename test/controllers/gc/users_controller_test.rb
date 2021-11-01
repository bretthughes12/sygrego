require "test_helper"
require 'pp'

class Gc::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    admin_role = FactoryBot.create(:role, name: 'admin')
    gc_role = FactoryBot.create(:role, name: 'gc')
    church_rep_role = FactoryBot.create(:role, name: 'church_rep')
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @church_rep = FactoryBot.create(:user)
    
    @user.roles.delete(admin_role)
    @user.roles << gc_role
    @user.groups << @group

    @church_rep.roles.delete(admin_role)
    @church_rep.roles << church_rep_role
    @church_rep.groups << @group

    sign_in @user
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
