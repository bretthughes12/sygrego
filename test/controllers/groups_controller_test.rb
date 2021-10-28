require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @admin_role = FactoryBot.create(:role, name: 'admin')
    @gc_role = FactoryBot.create(:role, name: 'gc')
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    
    @user.roles.delete(@admin_role)
    @user.roles << @gc_role
    @user.groups << @group
    
    sign_in @user
  end

  test "should show available groups" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    @user.groups << group

    get available_groups_groups_url

    assert_response :success
  end

  test "should show available groups for an admin" do
    sign_out @user

    user = FactoryBot.create(:user)
    sign_in user

    get available_groups_groups_url

    assert_response :success
  end

  test "should show available groups when editing a group" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    @user.groups << group

    patch switch_group_url(group)
    assert_equal group.abbr, session["current_group"]

    get available_groups_groups_url

    assert_response :success
  end

  test "should switch groups" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    @user.groups << group

    patch switch_group_url(group)

    assert_redirected_to home_gc_info_url
    assert_equal group.abbr, session["current_group"]
  end
end
