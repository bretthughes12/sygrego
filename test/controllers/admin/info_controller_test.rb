require "test_helper"

class Admin::InfoControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:audit_trail)
    @user = FactoryBot.create(:user, :admin)
    @sport = FactoryBot.create(:sport)
    
    sign_in @user
  end

  test "should get home screen" do
    get home_admin_info_url

    assert_response :success
  end

  test "should get tech stats" do
    get tech_stats_admin_info_url

    assert_response :success
  end
end
