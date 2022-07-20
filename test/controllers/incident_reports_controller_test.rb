require "test_helper"

class IncidentReportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
  end

  test "should get new" do
    get new_incident_report_url

    assert_response :success
  end

  test "should create incident report" do
    assert_difference('IncidentReport.count') do
      post incident_reports_path, params: { incident_report: FactoryBot.attributes_for(:incident_report) }
    end

    assert_response :redirect
    assert_match /Thanks for reporting/, flash[:notice]
  end
end
