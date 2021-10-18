require "test_helper"

class RolesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @group1 = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: @group1)
    @group2 = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: @group2)
    
    sign_in @user
  end

  test "should show available roles" do
    get available_roles_roles_url

    assert_response :success
  end

  test "should switch roles" do
    role = FactoryBot.create(:role, name: 'gc')

    patch switch_role_url(role)

    assert_redirected_to home_gc_info_url
  end

  test "should use session for current group" do
    role = FactoryBot.create(:role, name: 'gc')
    @user.roles << role
    @user.groups << @group1

    patch switch_group_url(@group1)
    assert_equal "gc", session["current_role"]

    get available_roles_roles_url

    assert_response :success
    assert_equal "gc", session["current_role"]
  end

  test "should use users groups for current group" do
    role = FactoryBot.create(:role, name: 'gc')
    @user.roles << role
    @user.groups << @group1
    @user.groups << @group2

    get available_roles_roles_url

    assert_response :success
  end
end 
