require "test_helper"

class Admin::InfoControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:audit_trail)
    @user = FactoryBot.create(:user)
    @sport = FactoryBot.create(:sport,
                                lock_version: 1)
    sign_in @user
  end

  test "should get tech stats" do
    get tech_stats_admin_info_url

    assert_response :success
  end
end
