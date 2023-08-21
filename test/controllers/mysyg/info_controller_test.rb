require "test_helper"

class Mysyg::InfoControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :participant)
    @mysyg_setting = FactoryBot.create(:mysyg_setting)
    @group = @mysyg_setting.group
    FactoryBot.create(:event_detail, group: @group)
    @participant = FactoryBot.create(:participant, group: @group)
    @user.groups << @group
    @user.participants << @participant

    sign_in @user
  end

  test "should get home page" do
    get home_mysyg_info_url(group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should get finance page" do
    get finance_mysyg_info_url(group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should get other home page when not participant" do
    sign_out @user
    gc_user = FactoryBot.create(:user, :gc)
    group = FactoryBot.create(:group)
    gc_user.groups << group
    sign_in gc_user

    get home_mysyg_info_url(group: @group.mysyg_setting.mysyg_name)

    assert_redirected_to home_gc_info_url
  end

  test "should get sign in page when gc not signed in" do
    sign_out @user

    get home_mysyg_info_url(group: @group.mysyg_setting.mysyg_name)

    assert_redirected_to new_user_session_url
  end
end
