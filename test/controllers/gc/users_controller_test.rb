require "test_helper"
require 'pp'

class Gc::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    admin_role = FactoryBot.create(:role, name: 'admin')
    gc_role = FactoryBot.create(:role, name: 'gc')
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    
    @user.roles.delete(admin_role)
    @user.roles << gc_role
    @user.groups << @group

    sign_in @user
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
