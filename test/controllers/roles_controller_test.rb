require "test_helper"

class RolesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @group1 = FactoryBot.create(:group)
    @group2 = FactoryBot.create(:group)
    @admin = Role.find_by_name('admin')
    
    sign_in @user
  end

  test "should show available roles" do
    get available_roles_roles_url

    assert_response :success
  end

  test "should switch roles" do
    role = FactoryBot.create(:role, :gc)

    patch switch_role_url(role)

    assert_redirected_to home_gc_info_url
  end

  test "should switch roles for an admin" do
    patch switch_role_url(@admin)

    assert_redirected_to home_admin_info_url
  end

  test "should switch roles to participant" do
    FactoryBot.create(:event_detail, group: @group1)
    FactoryBot.create(:mysyg_setting, group: @group1)
    participant = FactoryBot.create(:participant, group: @group1)
    @user.participants << participant
    @user.reload
    @group1.reload
    role = FactoryBot.create(:role, :participant)

    patch switch_role_url(role)

    assert_redirected_to home_mysyg_info_url(@group1.mysyg_setting.mysyg_name)
  end

  test "should use session for current group" do
    role = FactoryBot.create(:role, :gc)
    @user.roles << role
    @user.groups << @group1

    patch switch_group_url(@group1)
    assert_equal "gc", session["current_role"]

    get available_roles_roles_url

    assert_response :success
    assert_equal "gc", session["current_role"]
  end

  test "should use users groups for current group" do
    role = FactoryBot.create(:role, :gc)
    @user.roles << role
    @user.groups << @group1
    @user.groups << @group2

    get available_roles_roles_url

    assert_response :success
  end
end 
