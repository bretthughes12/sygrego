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

  test "should get edit functionality" do
    get edit_functionality_admin_setting_url(@setting)

    assert_response :success
  end

  test "should get edit fees" do
    get edit_fees_admin_setting_url(@setting)

    assert_response :success
  end

  test "should get edit divisions" do
    get edit_divisions_admin_setting_url(@setting)

    assert_response :success
  end

  test "should get edit sports factors" do
    get edit_sports_factors_admin_setting_url(@setting)

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

  test "should update functionality settings" do
    patch update_functionality_admin_setting_url(@setting), params: { setting: { syg_is_happening: true } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_equal true, @setting.syg_is_happening
  end

  test "should not update functionality settings with errors" do
    patch update_functionality_admin_setting_url(@setting), params: { setting: { new_group_sports_allocation_factor: 10.5 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_not_equal 10.5, @setting.new_group_sports_allocation_factor
  end

  test "should update fee settings" do
    patch update_fees_admin_setting_url(@setting), params: { setting: { full_fee: 120 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_equal 120, @setting.full_fee
  end

  test "should not update fees settings with errors" do
    patch update_fees_admin_setting_url(@setting), params: { setting: { full_fee: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_not_equal "a", @setting.full_fee
  end

  test "should update division settings" do
    patch update_divisions_admin_setting_url(@setting), params: { setting: { small_division_ceiling: 10 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_equal 10, @setting.small_division_ceiling
  end

  test "should not update division settings with errors" do
    patch update_divisions_admin_setting_url(@setting), params: { setting: { small_division_ceiling: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_not_equal "a", @setting.small_division_ceiling
  end

  test "should update sports allocation factors" do
    patch update_sports_factors_admin_setting_url(@setting), params: { setting: { new_group_sports_allocation_factor: 10 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_equal 10, @setting.new_group_sports_allocation_factor
  end

  test "should not update sports allocation factors with errors" do
    patch update_sports_factors_admin_setting_url(@setting), params: { setting: { new_group_sports_allocation_factor: 10.5 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @setting.reload

    assert_not_equal "10.5", @setting.new_group_sports_allocation_factor
  end
end
