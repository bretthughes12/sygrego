require "test_helper"

class Admin::MysygSettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @mysyg_setting = FactoryBot.create(:mysyg_setting)
    
    sign_in @user
  end

  test "should get index" do
    get admin_mysyg_settings_url

    assert_response :success
  end

  test "should search mysyg settings" do
    get search_admin_mysyg_settings_url

    assert_response :success
  end

  test "should download mysyg settings data" do
    get admin_mysyg_settings_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show mysyg setting" do
    get admin_mysyg_setting_url(@mysyg_setting)

    assert_response :success
  end

  test "should not show non existent mysyg setting" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_mysyg_setting_url(12345678)
    }
  end

  test "should get edit" do
    get edit_admin_mysyg_setting_url(@mysyg_setting)

    assert_response :success
  end

  test "should update mysyg settings" do
    patch admin_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { approve_option: "Strict" } }

    assert_redirected_to admin_mysyg_settings_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_equal "Strict", @mysyg_setting.approve_option
  end

  test "should not update mysyg settings with errors" do
    patch admin_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { approve_option: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_not_equal "a", @mysyg_setting.approve_option
  end

  test "should get new import" do
    get new_import_admin_mysyg_settings_url

    assert_response :success
  end

  test "should import mysyg settings" do
    group = FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('mysyg_setting.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    assert_no_difference('MysygSetting.count') do
      post import_admin_mysyg_settings_url, params: { mysyg_setting: { file: file }}
    end

    assert_redirected_to admin_mysyg_settings_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import mysyg settings when the file is not csv" do
    group = FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('MysygSetting.count') do
      post import_admin_mysyg_settings_url, params: { mysyg_setting: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.xlsx' format/, flash[:notice]
  end
end
