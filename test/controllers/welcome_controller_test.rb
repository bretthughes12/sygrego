require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @admin_role = FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    FactoryBot.create(:group)
  end

  test "admin user should land on admin welcome page" do
    sign_in @user

    assert_redirected_to root_url
    follow_redirect!
    assert_redirected_to admin_sports_url
  end

  test "gc user should land on group info page" do
    gc_role = FactoryBot.create(:role, name: 'gc')
    @user.roles.delete(@admin_role)
    @user.roles << gc_role
    sign_in @user

    assert_redirected_to root_url
    follow_redirect!
    assert_redirected_to home_gc_info_url
  end

  test "church_rep user should land on group info page" do
    church_rep_role = FactoryBot.create(:role, name: 'church_rep')
    @user.roles.delete(@admin_role)
    @user.roles << church_rep_role
    sign_in @user

    assert_redirected_to root_url
    follow_redirect!
    assert_redirected_to home_gc_info_url
  end

  test "participant user should land on group info page" do
    participant_role = FactoryBot.create(:role, name: 'participant')
    @user.roles.delete(@admin_role)
    @user.roles << participant_role
    sign_in @user

    assert_redirected_to root_url
    follow_redirect!
    assert_redirected_to home_gc_info_url
  end
end
