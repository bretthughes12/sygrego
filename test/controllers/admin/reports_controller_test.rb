require "test_helper"

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:audit_trail)
    @user = FactoryBot.create(:user, :admin)
    20.times do
      FactoryBot.create(:participant)
    end
    
    sign_in @user
  end

  test "should get finance summary" do
    get finance_summary_admin_reports_url

    assert_response :success
  end
end
