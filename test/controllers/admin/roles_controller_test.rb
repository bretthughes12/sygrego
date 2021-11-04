require "test_helper"

class Admin::RolesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @role = FactoryBot.create(:role)
    
    sign_in @user
  end

  test "should get index" do
    get admin_roles_url

    assert_response :success
  end

  test "should show role" do
    get admin_role_url(@role)

    assert_response :success
  end

  test "should not show non existent role" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_role_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_role_url

    assert_response :success
  end

  test "should create role" do
    assert_difference('Role.count') do
      post admin_roles_path, params: { role: FactoryBot.attributes_for(:role) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create role with errors" do
    assert_no_difference('Role.count') do
      post admin_roles_path, params: { 
                                role: FactoryBot.attributes_for(:role,
                                name: "Too long..............") }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_role_url(@role)

    assert_response :success
  end

  test "should update role" do
    patch admin_role_url(@role), params: { role: { name: "Hello World" } }

    assert_redirected_to admin_roles_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @role.reload

    assert_equal "Hello World", @role.name
  end

  test "should not update role with errors" do
    patch admin_role_url(@role), params: { role: { name: "Too Long...................................................." } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @role.reload

    assert_not_equal "Too Long....................................................", @role.name
  end

  test "should destroy role" do
    assert_difference("Role.count", -1) do
      delete admin_role_url(@role)
    end

    assert_redirected_to admin_roles_path
  end

  test "should not destroy non existent role" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_role_url(12345678)
    }
  end

  test "should add a role to a user" do
    role = FactoryBot.create(:role, name: 'gc')

    patch add_admin_user_role_url(user_id: @user.id, id: role)

    assert_redirected_to edit_admin_user_path(@user)

    @user.reload

    assert_equal true, @user.roles.include?(role)
  end

  test "should remove a role from a user" do
    role = FactoryBot.create(:role, name: 'gc')
    @user.roles << role

    delete purge_admin_user_role_url(user_id: @user.id, id: role)

    assert_redirected_to edit_admin_user_path(@user)

    @user.reload

    assert_equal false, @user.roles.include?(role)
  end
end 
