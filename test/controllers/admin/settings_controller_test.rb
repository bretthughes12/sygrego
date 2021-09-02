require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    @setting = FactoryBot.create(:setting)
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  test "should show settings" do
    get admin_setting_url(@setting)

    assert_response :success
  end

  test "should not show non existent setting" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_setting_url(12345678)
    }
  end

  test "should get edit" do
    get edit_admin_setting_url(@setting)

    assert_response :success
  end

  test "should update setting" do
    patch admin_setting_url(@setting), params: { setting: { new_group_sports_allocation_factor: 10 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_equal 10, @setting.new_group_sports_allocation_factor
  end

  test "should not update setting with errors" do
    patch admin_setting_url(@setting), params: { setting: { new_group_sports_allocation_factor: 10.5 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_not_equal 10.5, @setting.new_group_sports_allocation_factor
  end
end
