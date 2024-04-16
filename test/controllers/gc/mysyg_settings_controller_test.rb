require "test_helper"

class Gc::MysygSettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @group = FactoryBot.create(:group)
    @mysyg_setting = FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, 
      group: @group)
    @user.groups << @group
    
    sign_in @user
  end

  test "should get edit" do
    get edit_gc_mysyg_setting_url(@mysyg_setting)

    assert_response :success
  end

  test "should edit team sports" do
    get edit_team_sports_gc_mysyg_setting_url(@mysyg_setting)

    assert_response :success
  end

  test "should edit individual sports" do
    get edit_indiv_sports_gc_mysyg_setting_url(@mysyg_setting)

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

  test "should update team sports" do
    patch update_team_sports_gc_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { team_sport_view_strategy: "Show none" } }

    assert_redirected_to home_gc_info_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_equal "Show none", @mysyg_setting.team_sport_view_strategy
  end

  test "should not update team sport settings with errors" do
    patch update_team_sports_gc_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { team_sport_view_strategy: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_not_equal "Invalid", @mysyg_setting.team_sport_view_strategy
  end

  test "should update individual sports" do
    patch update_indiv_sports_gc_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { indiv_sport_view_strategy: "Show none" } }

    assert_redirected_to home_gc_info_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_equal "Show none", @mysyg_setting.indiv_sport_view_strategy
  end

  test "should not update individual sport settings with errors" do
    patch update_indiv_sports_gc_mysyg_setting_url(@mysyg_setting), params: { mysyg_setting: { indiv_sport_view_strategy: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @mysyg_setting.reload

    assert_not_equal "Invalid", @mysyg_setting.indiv_sport_view_strategy
  end
end
