require "test_helper"

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:audit_trail)
    @user = FactoryBot.create(:user, :admin)
    
    sign_in @user
  end

  test "should get fees table" do
    get fees_admin_reports_url

    assert_response :success
  end

  test "should get finance summary" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: group)
    FactoryBot.create(:event_detail, group: group)

    20.times do
      FactoryBot.create(:participant, group: group)
    end

    get finance_summary_admin_reports_url

    assert_response :success
  end

  test "should get service preferences" do
    5.times do
      FactoryBot.create(:event_detail)
    end

    get service_preferences_admin_reports_url

    assert_response :success
  end

  test "should get gender summary" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    FactoryBot.create(:participant, group: group, gender: "U")

    get gender_summary_admin_reports_url

    assert_response :success
  end
end
