require "test_helper"

class Gc::MysygSettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @mysyg_setting = FactoryBot.create(:mysyg_setting)
    @user.groups << @mysyg_setting.group
    
    sign_in @user
  end

  test "should get edit" do
    get edit_gc_mysyg_setting_url(@mysyg_setting)

    assert_response :success
  end

  test "should update mysyg settings" do
    patch gc_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { approve_option: "Tolerant" } }

    assert_redirected_to home_gc_info_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_equal "Tolerant", @mysyg_setting.approve_option
  end

  test "should update mysyg settings as church_rep" do
    sign_out @user

    church_rep_user = FactoryBot.create(:user, :church_rep)
    church_rep_user.groups << @mysyg_setting.group
    sign_in church_rep_user

    patch gc_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { approve_option: "Tolerant" } }

    assert_redirected_to home_gc_info_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_equal "Tolerant", @mysyg_setting.approve_option
  end

  test "should not update mysyg settings with errors" do
    patch gc_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { approve_option: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_not_equal "a", @mysyg_setting.approve_option
  end
end
