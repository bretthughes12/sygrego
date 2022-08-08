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
end
